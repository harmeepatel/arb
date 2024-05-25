const std = @import("std");
const recipe = @import("recipe");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var wasm_alloc = gpa.allocator();
// var wasm_alloc = std.heap.wasm_allocator;

export fn createImage(ptr: [*]const u8, len: usize) void {
    const json: []const u8 = ptr[0..len];
    const a = recipe.Recipe.init(wasm_alloc, json) catch {
        @panic("falied to initialize recipe");
    };
    defer a.deinit();
}

export fn allocBytes(len: usize) ?[*]u8 {
    return if (wasm_alloc.alloc(u8, len)) |slice| slice.ptr else |_| null;
}

export fn freeBytes(ptr: ?[*]const u8, len: usize) void {
    if (ptr) |valid_ptr| wasm_alloc.free(valid_ptr[0..len]);
}
