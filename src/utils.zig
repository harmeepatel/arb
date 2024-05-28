const Allocator = @import("std").mem.Allocator;

pub fn readInputFile(allocator: Allocator, path: []const u8) ![]const u8 {
    const file = try @import("std").fs.cwd().openFile(path, .{});
    defer file.close();
    const stat = try file.stat();
    const fileSize = stat.size;
    return try file.reader().readAllAlloc(allocator, fileSize);
}

const char_len: comptime_int = 95;
pub fn getChars() [char_len]i32 {
    var a: [char_len]i32 = [_]i32{0} ** char_len;
    for (0..a.len) |idx| {
        a[idx] = 32 + @as(i32, @intCast(idx));
    }
    return a;
}
