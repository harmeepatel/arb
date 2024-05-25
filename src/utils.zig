const Allocator = @import("std").mem.Allocator;

pub fn readInputFile(allocator: Allocator, path: []const u8) ![]const u8 {
    const file = try @import("std").fs.cwd().openFile(path, .{});
    defer file.close();
    const stat = try file.stat();
    const fileSize = stat.size;
    return try file.reader().readAllAlloc(allocator, fileSize);
}
