const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");
const utils = @import("utils.zig");
const Recipe = @import("recipe.zig").Recipe;

const AspectRation = struct { x: f32, y: f32 };

const recipe_buf_size = 1024 * 8;
const edge_padding: f32 = 64.0;

const path_json_recipe = "data/recipe.json";
const path_font_regular = "font/line_seed_sans/LINESeedSans_Rg.otf";
const path_font_bold = "font/line_seed_sans/LINESeedSans_Bd.otf";

var font_regular: rl.Font = undefined;
var font_bold: rl.Font = undefined;

const factor = 800;
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

    const r = try Recipe.init(aapa_alloc, json_string);
    // defer aapa_alloc.free(r); // TODO: fix this, cannot free anything till the program ends

    init();
    _ = try update(&r);
}

fn init() void {
    _ = rl.initWindow(screen_width, screen_heigt, "Aramse Recipe Builder");
    rl.setTargetFPS(1);
    const load_font_size = 240;
    var chars = utils.getChars();
    font_regular = rl.loadFontEx(path_font_regular, load_font_size, &chars);
    font_bold = rl.loadFontEx(path_font_bold, load_font_size, &chars);
    // font_regular = rl.loadFont(path_font_regular);
    // font_bold = rl.loadFont(path_font_bold);
}

fn update(r: *const Recipe) !void {
    // const c_str = try std.heap.c_allocator.dupeZ(u8, r.name);

    // TODO: idk what is this -> more research as always
    rl.setTextureFilter(font_regular.texture, @intFromEnum(rl.TextureFilter.texture_filter_bilinear));

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        _ = try drawLabel(r);

        rl.clearBackground(rl.Color.white);
    }
}

fn drawLabel(r: *const Recipe) !void {
    var pos = rl.Vector2.init(edge_padding, edge_padding);
    const rect = rl.Rectangle.init(pos.x, pos.y, aspect_ratio.x * 200, aspect_ratio.y * 200);
    const color = rl.Color.fromHSV(11, 0.25, 1);

    const max_len = 3;
    var buf: [max_len]u8 = undefined;
    const coffee_str: [:0]const u8 = try std.fmt.bufPrintZ(&buf, "{d}", .{r.coffee});

    rl.drawRectangleRounded(rect, 0.2, 128, color);
    // labelText modifyies the pos
    labelText(&pos, "Author", r.name);
    labelText(&pos, "Brewer", r.brewer);
    labelText(&pos, "Coffee", coffee_str);
    labelText(&pos, "Grind Size{", r.grind);
}

fn labelText(pos: *rl.Vector2, label: [:0]const u8, value: [:0]const u8) void {
    const y_off = 8;
    const font_size = 32;
    const text_padding = rl.Vector2.init(edge_padding / 3, edge_padding / 3 - y_off);
    const m = rl.measureTextEx(font_regular, label, font_size, 0);

    const label_pos = rl.Vector2.init(pos.x + text_padding.x, pos.y + text_padding.y);
    rl.drawTextEx(font_regular, label, label_pos, font_size, 0, rl.Color.black);

    // const value_pos = rl.Vector2.init(pos.x + text_padding.x + m.x + m.y, pos.y + text_padding.y);
    const value_pos = rl.Vector2.init(256, pos.y + text_padding.y);
    rl.drawTextEx(font_bold, value, value_pos, font_size, 0, rl.Color.black);

    pos.y = pos.y + m.y;
}
