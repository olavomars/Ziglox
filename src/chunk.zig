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
        return Self{ .count = 0, .capacity = 0, .code = null };
    }

    pub fn writeChunk(self: *Self, byte: u8) !void {
        if (self.capacity < self.count + 1) {
            const oldCapacity = self.capacity;
            self.capacity = if (oldCapacity < 8) 8 else oldCapacity * 2;
            self.items = try reallocate(self.allocator, self.items, old_capacity, self.capacity);
        }
        self.items[self.count] = byte;
        self.count += 1;
    }
};
