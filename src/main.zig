const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");
const utils = @import("utils.zig");
const Recipe = @import("recipe.zig").Recipe;

const AspectRation = struct { x: f32, y: f32 };

const buf_size_recipe = 1024 * 8;
const padding_edge: f32 = 64.0;

const path_json_recipe = "data/recipe.min.json";
const path_font = "font/gnu_free_font/";
const path_font_regular = path_font ++ "Sans.ttf";
const path_font_bold = path_font ++ "SansBold.ttf";
// const path_font_regular = "font/line_seed_sans/LINESeedSans_Rg.otf";
// const path_font_bold = "font/line_seed_sans/LINESeedSans_Bd.otf";

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
        _ = aapa.deinit();
        rl.closeWindow();
    }

    const json_string = utils.readInputFile(aapa_alloc, path_json_recipe);
    defer aapa_alloc.free(json_string);

    const r = Recipe.init(aapa_alloc, json_string);
    // defer aapa_alloc.free(r); // TODO: fix this, cannot free anything till the program ends

    init();
    _ = try update(&r);
}

fn init() void {
    _ = rl.initWindow(screen_width, screen_heigt, "Aramse Recipe Builder");
    rl.setTargetFPS(1);
    const load_font_size = 512;
    var chars = utils.getChars();
    font_regular = rl.loadFontEx(path_font_regular, load_font_size, &chars);
    font_bold = rl.loadFontEx(path_font_bold, load_font_size, &chars);
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
    var pos = rl.Vector2.init(padding_edge, padding_edge);
    const rect = rl.Rectangle.init(pos.x, pos.y, aspect_ratio.x * 200, aspect_ratio.y * 200);
    const color = rl.Color.fromHSV(180, 0.8, 0.85);

    var buf_recipe_coffee_weight: [4]u8 = undefined;
    const str_coffee: [:0]const u8 = try std.fmt.bufPrintZ(&buf_recipe_coffee_weight, "{d}g", .{r.coffee_g});

    rl.drawRectangleRounded(rect, 0.2, 128, color);
    // labelText modifyies the pos
    labelText(&pos, "Author", r.name);
    labelText(&pos, "Brewer", r.brewer);
    labelText(&pos, "Coffee", str_coffee);
    labelText(&pos, "Grind Size", r.grind_size);
    // labelText(&pos, "Water", r.water_temp);
    labelText(&pos, "Filter", r.filter);

    _ = try labelText2(&pos, r);
}

fn labelText2(pos: *rl.Vector2, r: *const Recipe) !*const [7][]const u8 {
    _ = pos;
    const pos_label = rl.Vector2.init(0, 0);
    _ = pos_label;

    var buf: [64]u8 = undefined;
    const str_coffee: [:0]const u8 = try std.fmt.bufPrintZ(&buf, "{d}g", .{r.coffee_g});
    const str_water: [:0]const u8 = try std.fmt.bufPrintZ(&buf, "{d}g", .{r.water_g});

    const labels = .{ "Author", "Brewer", "Coffee", "Grind Size", "Water", "Filter", "Stirrer" };
    const values = .{ r.name, r.brewer, str_coffee, r.grind_size, str_water, r.filter, r.stirrer };

    var max_label = std.ArrayList(u8).init(aapa_alloc);
    var max_value = std.ArrayList(u8).init(aapa_alloc);

    var max_label_len: usize = 0;
    var max_value_len: usize = 0;
    inline for (labels, values) |l, v| {
        max_label_len = @max(l.len, max_label_len);
        max_value_len = @max(v.len, max_value_len);
    }
    for (0..max_label_len) |_| {
        try max_label.appendSlice("");
    }
    for (0..max_value_len) |_| {
        try max_value.appendSlice(" ");
    }
    print("{d}\n", .{max_label_len});
    print("{d}\n", .{max_value_len});

    const size_font = 32;
    const str_max_label = try std.fmt.bufPrintZ(&buf, "{s}", .{max_label.items});
    const str_max_value = try std.fmt.bufPrintZ(&buf, "{s}", .{max_value.items});
    const m_label = rl.measureTextEx(font_regular, str_max_label, size_font, 0);
    const m_value = rl.measureTextEx(font_regular, str_max_value, size_font, 0);
    print("{any}\n", .{m_label});
    print("{any}\n", .{m_value});

    return &labels;
}

fn labelText(pos: *rl.Vector2, label: [:0]const u8, value: [:0]const u8) void {
    const y_off = 8;
    const size_font = 32;
    const padding_text = rl.Vector2.init(padding_edge / 3, padding_edge / 3 - y_off);
    const m = rl.measureTextEx(font_regular, label, size_font, 0);

    const label_pos = rl.Vector2.init(pos.x + padding_text.x, pos.y + padding_text.y);
    rl.drawTextEx(font_regular, label, label_pos, size_font, 0, rl.Color.black);

    // const value_pos = rl.Vector2.init(pos.x + text_padding.x + m.x + m.y, pos.y + text_padding.y);
    const value_pos = rl.Vector2.init(256, pos.y + padding_text.y);
    rl.drawTextEx(font_bold, value, value_pos, size_font, 0, rl.Color.black);

    pos.y = pos.y + m.y;
}
