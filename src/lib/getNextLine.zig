const std = @import("std");

const BUFFER_SIZE = @import("constants.zig").BUFFER_SIZE;

pub fn getNextLine(allocator: std.mem.Allocator) ![] u8 {
    const reader = std.io.getStdIn().reader();

    const stats = reader.context;
    std.debug.print("{?}", .{ stats });

    return reader.readUntilDelimiterAlloc(allocator, '\n', BUFFER_SIZE);
}