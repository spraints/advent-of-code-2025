const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = std.process.args();
    if (!args.skip()) {
        return;
    }
    if (args.next()) |input| {
        std.debug.print("input: {s}\n", .{input});
        const file = try std.fs.cwd().openFile(input, .{});
        defer file.close();

        const file_contents = try file.readToEndAlloc(allocator, 1024 * 1024 * 10); // 10MB max
        defer allocator.free(file_contents);

        std.debug.print("input contents:\n{s}\n", .{file_contents});
    }
}
