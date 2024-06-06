const Allocator = @import("std").mem.Allocator;
const exit = @import("std").process.exit;
const debug_print = @import("std").debug.print;

pub fn readInputFile(allocator: Allocator, path: []const u8) []const u8 {
    const file = @import("std").fs.cwd().openFile(path, .{}) catch |err| {
        fatal("unable to open {s} : {s}", .{ path, @errorName(err) });
    };
    defer file.close();

    const fileSize = blk: {
        const stat = file.stat() catch |err| {
            fatal("unable to get stats for {s} : {s}", .{ path, @errorName(err) });
        };
        break :blk stat.size;
    };

    return blk: {
        const a = file.reader().readAllAlloc(allocator, fileSize) catch |err| {
            fatal("unable to read file {s} : {s}", .{ path, @errorName(err) });
        };
        break :blk a;
    };
}

const char_len: comptime_int = 95;
pub fn getChars() [char_len]i32 {
    var a: [char_len]i32 = [_]i32{0} ** char_len;
    for (0..a.len) |idx| {
        a[idx] = 32 + @as(i32, @intCast(idx));
    }
    return a;
}

pub fn fatal(comptime msg: []const u8, args: anytype) noreturn {
    debug_print("\n" ++ msg ++ "\n", args);
    exit(1);
}
