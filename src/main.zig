const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");
const Recipe = @import("recipe.zig").Recipe;
const utils = @import("utils.zig");

const AspectRation = struct { x: f32, y: f32 };

const recipe_buf_size = 1024 * 8;
const edge_padding: f32 = 50.0;

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
    const r = try Recipe.init(aapa_alloc, json_string);
    // defer aapa_alloc.free(r); // TODO: fix this, cannot free anything till the program ends

    init();
    _ = try update(&r);
}

fn init() void {
    _ = rl.initWindow(screen_width, screen_heigt, "test");
    rl.setTargetFPS(1);
    font_regular = rl.loadFont(path_font_regular);
    font_bold = rl.loadFont(path_font_bold);
}

fn update(r: *const Recipe) !void {
    // const c_str = try std.heap.c_allocator.dupeZ(u8, r.name);

    // TODO: idk what is this -> more research as always
    rl.setTextureFilter(font_regular.texture, @intFromEnum(rl.TextureFilter.texture_filter_bilinear));

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        drawLabel(r);

        rl.clearBackground(rl.Color.white);
    }
}

fn labelText(rect: *const rl.Rectangle, label: [:0]const u8, value: [:0]const u8) void {
    const text_padding = 10;
    const label_pos = rl.Vector2.init(rect.x + text_padding, rect.y + text_padding);
    const value_pos = rl.Vector2.init(rect.x + text_padding + 80, rect.y + text_padding);
    rl.drawTextEx(font_regular, label, label_pos, 24, 0, rl.Color.black);
    rl.drawTextEx(font_bold, value, value_pos, 24, 0, rl.Color.black);
}

fn drawLabel(r: *const Recipe) void {
    const pos = rl.Vector2.init(edge_padding, edge_padding);
    const rect = rl.Rectangle.init(pos.x, pos.y, aspect_ratio.x * 100, aspect_ratio.y * 100);
    const color = rl.Color.fromHSV(11, 0.25, 1);

    rl.drawRectangleRounded(rect, 0.2, 128, color);
    labelText(&rect, "Recipe:", r.name);
}
