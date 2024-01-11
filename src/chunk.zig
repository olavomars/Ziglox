const std = @import("std");
const Allocator = std.mem.Allocator;

pub const OpCode = enum(u8) {
    OP_RETURN,
};

pub const Chunk = struct {
    const Self = @This();

    const BytesArray = std.ArrayList(u8);

    count: usize,
    capacity: usize,
    code: null,

    pub fn initChunk(allocator: *Allocator) Self {
        return Self{ .count = 0, .capacity = 0, .code = null, .allocator = allocator };
    }

    pub fn writeChunk(self: *Self, byte: u8) !void {
        if (self.capacity < self.count + 1) {
            const oldCapacity = self.capacity;
            self.capacity = grow_capacity(self.capacity);
            self.code = try reallocate(self.allocator, *self.items, @TypeOf(self.code), old_capacity, self.capacity);
        }
        self.code[self.count] = byte;
        self.count += 1;
    }

    fn growCapacity(capacity: usize) usize {
        return if (capacity < 8) 8 else capacity * 2;
    }
};

fn reallocate(allocator: *Allocator, pointer: *void, comptime T: type, oldSize: usize, newSize: usize) !T {
    if (newSize == 0) {
        allocator.free(pointer);
        return null;
    }
    const result = try allocator.realloc(T, newSize, oldSize, pointer);

    if (result == null) {
        return std.debug.panic("Memory allocation failed");
    }

    return result;
}

test "create a DynamicArray" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer {
        const leaked = gpa.deinit();
        if (leaked) expect(false) catch @panic("The list is leaking");
    }

    var chunk = initChunk(gpa);

    defer arr.deinit();

    try arr.writeChunk(5);
    try expect(arr.code[0] == 5);
    try expect(arr.count == 1);

    try arr.writeChunk(1);
    try arr.writeChunk(2);
    try arr.writeChunk(3);
    try arr.writeChunk(4);
    try arr.writeChunk(5);
    try arr.writeChunk(6);
    try arr.writeChunk(7);
    try arr.writeChunk(8);
    try arr.writeChunk(9);
    try arr.writeChunk(10);
    try arr.writeChunk(11);
    try arr.writeChunk(12);
    try arr.writeChunk(13);
    try arr.writeChunk(14);
    try expect(arr.items[10] == 10);
    arr.deinit();

    try expect(arr.count == 0);
    try expect(arr.capacity == 0);
}
