const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;

const getNextLine = @import("./lib/getNextLine.zig").getNextLine;

pub fn main() !void {
    const stdOut = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    const lex = Lexer.init("test");
    _ = lex;

    var shouldExit = false;
    while (shouldExit == false) {
        try stdOut.print("$> ", .{});
        
        const input = try getNextLine(allocator);
        defer allocator.free(input);

        try stdOut.print("input len: {}\n", .{input.len});

        if (std.mem.eql(u8, input[0..input.len - 1], "exit")) {
            shouldExit = true;
        }


        try stdOut.print("You entered {s}\n", .{ input });
    }

    try stdOut.print("Goodbye!\n", .{ });
}
