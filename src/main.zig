const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");
const recipe = @import("recipe.zig");
const utils = @import("utils.zig");

const AspectRation = struct { x: f32, y: f32 };

const recipe_buf_size = 1024 * 8;

const path_json_recipe = "data/recipe.json";
const path_font = "font/line_seed_sans/LINESeedSans_Rg.otf";
var font_line_seed: rl.Font = undefined;

const factor = 600;
const aspect_ratio = AspectRation{
    .x = 2.39,
    .y = 1,
};
const screen_width: u32 = @intFromFloat(aspect_ratio.x * factor);
const screen_heigt: u32 = @intFromFloat(aspect_ratio.y * factor);

var aapa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const aapa_alloc = aapa.allocator();

pub fn main() !void {
    defer {
        aapa.deinit();
        rl.closeWindow();
    }

    const json_string = try utils.readInputFile(aapa_alloc, path_json_recipe);
    defer aapa_alloc.free(json_string);

    var r: recipe.Recipe = undefined;
    try recipe.Recipe.init(aapa_alloc, json_string, &r);
    // defer aapa_alloc.free(r); // TODO: fix this, cannot free anything till the program ends

    init();
    _ = try update(r);
}

fn init() void {
    _ = rl.initWindow(screen_width, screen_heigt, "test");
    rl.setTargetFPS(1);
    font_line_seed = rl.loadFont(path_font);
}

fn update(r: recipe.Recipe) !void {
    _ = r;
    // const c_str = try std.heap.c_allocator.dupeZ(u8, r.name);

    // TODO: idk what is this -> more research as always
    rl.setTextureFilter(font_line_seed.texture, @intFromEnum(rl.TextureFilter.texture_filter_bilinear));
    const rect_label_bg = rl.Rectangle.init(50, 50, aspect_ratio.x * 100, aspect_ratio.y * 100);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        draw_label(rect_label_bg);

        rl.clearBackground(rl.Color.white);
    }
}
fn draw_label(rect: rl.Rectangle) void {
    rl.drawRectangleRounded(rect, 0.2, 128, rl.Color.sky_blue);
}
