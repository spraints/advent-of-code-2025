const std = @import("std");

const Range = struct { from_digits: u8, from: u64, to: u64 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input = try read_input(allocator);
    defer allocator.free(input);

    const State = enum { var r: Range = .{.from_digits=0, .from=0, .to=0}; from, to };

    var rangeList = std.ArrayList(Range).empty;
    defer rangeList.deinit(allocator);

    var parse_state = State.from;
    for (input) |c| {
        if (c == '\n') {
            continue;
        }
        // std.debug.print("{} {c} ({})\n", .{parse_state,c,State.r});
        switch (parse_state) {
            .from => {
                if (c == '-') {
                    parse_state = .to;
                } else {
                    State.r.from_digits += 1;
                    State.r.from = State.r.from * 10 + (c - '0');
                }
            },
            .to => {
                if (c == ',') {
                    try rangeList.append(allocator, State.r);
                    parse_state = .from;
                    State.r = .{.from_digits=0,.from=0,.to=0};
                } else {
                    State.r.to = State.r.to * 10 + (c - '0');
                }
            },
        }
    }
    if (parse_state == .to) {
        try rangeList.append(allocator, State.r);
    }

    const ranges = try rangeList.toOwnedSlice(allocator);
    defer allocator.free(ranges);

    var max: u64 = 0;
    for (ranges) |range| {
        if (range.to > max) {
            max = range.to;
        }
    }

    var invalid1: u64 = 0;
    var invalid2: u64 = 0;
    var seen = std.AutoHashMap(u64, void).init(allocator);
    defer seen.deinit();

    var l:u64 = 1;
    var r:u64 = 10;
    while (true) {
        var l2 = l * r + l;
        if (l2 > max) {
            break;
        }
        if (is_invalid(ranges, l2)) {
            invalid1 += l2;
            if (!seen.contains(l2)) {
                invalid2 += l2;
            }
            try seen.put(l2, {});
        }

        while (true) {
            l2 = l2 * r + l;
            if (l2 > max) {
                break;
            }
            if (!seen.contains(l2) and is_invalid(ranges, l2)) {
                invalid2 += l2;
                try seen.put(l2, {});
            }
        }

        l += 1;
        if (l == r) {
            r *= 10;
        }
    }

    std.debug.print("part 1: {}\npart 2: {}\n", .{invalid1, invalid2});
}

fn is_invalid(ranges: []Range, l2: u64) bool {
    for (ranges) |r| {
        if (r.from <= l2 and l2 <= r.to) {
            return true;
        }
    }
    return false;
}

// my aoc lib below here.

const InputError = error{
    InvalidArgs
};

fn read_input(allocator: std.mem.Allocator) ![]u8 {
    const input = try get_input_filename();
    const file = try std.fs.cwd().openFile(input, .{});
    defer file.close();

    return file.readToEndAlloc(allocator, 1024 * 1024 * 10); // 10MB max
}

fn get_input_filename() ![:0]const u8 {
    var args = std.process.args();
    if (!args.skip()) {
        return InputError.InvalidArgs;
    }
    return args.next() orelse InputError.InvalidArgs;
}
