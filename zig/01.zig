const std = @import("std");

const ClicksRes = struct {
    new_pos: i32,
    clicks: u32,
};

fn clicks(start: i32, dir: u8, dist: i32) ClicksRes {
    // std.debug.print("clicks {} {} {}\n", .{start,dir,dist});
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
    // std.debug.print("{} => {}({}) ~~~ {}/{}\n", .{start,new_real,new,q,ct});
    return ClicksRes{.new_pos = new_real, .clicks = ct};
}

test clicks {
    try std.testing.expectEqual(ClicksRes{.new_pos = 50, .clicks =0}, clicks(50,'L',0));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks =1}, clicks(50,'L',50));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =1}, clicks(50,'L',51));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =2}, clicks(50,'L',151));

    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks =0}, clicks(0,'L',0));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =0}, clicks(0,'L',1));
    try std.testing.expectEqual(ClicksRes{.new_pos = 1, .clicks =0}, clicks(0,'L',99));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks =1}, clicks(0,'L',100));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =1}, clicks(0,'L',101));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks =2}, clicks(0,'L',201));

    try std.testing.expectEqual(ClicksRes{.new_pos = 50, .clicks = 0}, clicks(50,'R',0));
    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks = 0}, clicks(50,'R',49));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks = 1}, clicks(50,'R',50));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks = 2}, clicks(50,'R',150));

    try std.testing.expectEqual(ClicksRes{.new_pos = 99, .clicks = 0}, clicks(0,'R',99));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks = 1}, clicks(0,'R',100));
    try std.testing.expectEqual(ClicksRes{.new_pos = 0, .clicks = 2}, clicks(0,'R',200));
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
        std.debug.print("input: {s}\n", .{input});
        const file = try std.fs.cwd().openFile(input, .{});
        defer file.close();

        const file_contents = try file.readToEndAlloc(allocator, 1024 * 1024 * 10); // 10MB max
        defer allocator.free(file_contents);

        // std.debug.print("input contents:\n{s}\n", .{file_contents});
    }
}
