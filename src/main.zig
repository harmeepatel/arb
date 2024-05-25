const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");
const recipe = @import("recipe.zig");
const utils = @import("utils.zig");

const AspectRation = struct { x: f32, y: f32 };

const recipe_buf_size = 1024 * 8;

const path_json_recipe = "data/recipe.json";
const path_font_regular = "font/line_seed_sans/LINESeedSans_Rg.otf";
const path_font_bold = "font/line_seed_sans/LINESeedSans_Bd.otf";

var font_regular: rl.Font = undefined;
var font_bold: rl.Font = undefined;

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

    // var r: recipe.Recipe = undefined;
    const r = try recipe.Recipe.init(aapa_alloc, json_string);
    // defer aapa_alloc.free(r); // TODO: fix this, cannot free anything till the program ends

    init();
    _ = try update(r);
}

fn init() void {
    _ = rl.initWindow(screen_width, screen_heigt, "test");
    rl.setTargetFPS(1);
    font_regular = rl.loadFont(path_font_regular);
    font_bold = rl.loadFont(path_font_bold);
}

fn update(r: recipe.Recipe) !void {
    // const c_str = try std.heap.c_allocator.dupeZ(u8, r.name);

    // TODO: idk what is this -> more research as always
    rl.setTextureFilter(font_regular.texture, @intFromEnum(rl.TextureFilter.texture_filter_bilinear));

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        draw_label(r);

        rl.clearBackground(rl.Color.white);
    }
}
fn draw_label(r: recipe.Recipe) void {
    const rect_label_bg = rl.Rectangle.init(50, 50, aspect_ratio.x * 100, aspect_ratio.y * 100);
    const color_label_bg = rl.Color.fromHSV(11, 0.25, 1);

    rl.drawRectangleRounded(rect_label_bg, 0.2, 128, color_label_bg);

    rl.drawTextEx(font_regular, r.name, rl.Vector2.init(0.0, 0.0), 32, 0, rl.Color.black);
}
