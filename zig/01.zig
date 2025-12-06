const std = @import("std");

const ClicksRes = struct {
    new_pos: i32,
    clicks: u32,
};

fn rotate(start: i32, dir: u8, dist: i32) ClicksRes {
    // std.debug.print("clicks start={} dir={c} dist={}\n", .{start,dir,dist});
    if (dist == 0) {
        return .{.new_pos = start, .clicks = 0};
    }
    const off = if (dir == 'L') -dist else dist;
    const new = start + off;
    const new_real = @mod(new, 100);
    const q = if (new > 0) @divTrunc(new, 100) else @divTrunc(new-100, 100);
    var ct: u32 = @abs(q);
    if (start == 0 and dir == 'L') {
        ct -= 1;
    }
    // std.debug.print("start={} => new={}({}) ~~~ q={}/ct={}\n", .{start,new_real,new,q,ct});
    return ClicksRes{.new_pos = new_real, .clicks = ct};
}

test rotate {
    try std.testing.expectEqual(ClicksRes{.new_pos = 50, .clicks =0}, rotate(50,'L',0));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks =1}, rotate(50,'L',50));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =1}, rotate(50,'L',51));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =2}, rotate(50,'L',151));

    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks =0}, rotate(0,'L',0));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =0}, rotate(0,'L',1));
    try std.testing.expectEqual(ClicksRes{.new_pos = 1, .clicks =0}, rotate(0,'L',99));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks =1}, rotate(0,'L',100));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =1}, rotate(0,'L',101));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =2}, rotate(0,'L',201));

    try std.testing.expectEqual(ClicksRes{.new_pos = 50, .clicks = 0}, rotate(50,'R',0));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks = 0}, rotate(50,'R',49));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks = 1}, rotate(50,'R',50));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks = 2}, rotate(50,'R',150));

    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks = 0}, rotate(0,'R',99));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks = 1}, rotate(0,'R',100));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks = 2}, rotate(0,'R',200));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = std.process.args();
    if (!args.skip()) {
        return;
    }
    if (args.next()) |input| {
        // std.debug.print("input: {s}\n", .{input});
        const file = try std.fs.cwd().openFile(input, .{});
        defer file.close();

        const file_contents = try file.readToEndAlloc(allocator, 1024 * 1024 * 10); // 10MB max
        defer allocator.free(file_contents);

        var lines = std.mem.splitSequence(u8, file_contents, &[_]u8{'\n'});
        var pos: i32 = 50;
        var zeroes: u32 = 0;
        var clicks: u32 = 0;
        while (lines.next()) |line| {
            // std.debug.print("line: {s}\n", .{line});
            const dir = line[0];
            const dist = try std.fmt.parseInt(i32, line[1..], 10);
            const res = rotate(pos, dir, dist);
            clicks += res.clicks;
            pos = res.new_pos;
            if (pos == 0) {
                zeroes += 1;
            }
            // std.debug.print("  => pos={}, clicks={} ({})\n", .{pos, clicks, res});
        }
        var stdout = std.fs.File.stdout().writerStreaming(&.{});
        try stdout.interface.print("part 1: {}\npart 2: {}\n", .{zeroes, clicks});
    }
}
