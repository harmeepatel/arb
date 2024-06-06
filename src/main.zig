const std = @import("std");
const print = std.debug.print;
const rl = @import("raylib");
const utils = @import("utils.zig");
const Recipe = @import("recipe.zig").Recipe;

const AspectRation = struct { x: f32, y: f32 };

const buf_size_recipe = 1024 * 8;
const padding_edge: f32 = 64.0;

const path_json_recipe = "data/recipe.min.json";
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
    var pos = rl.Vector2.init(padding_edge, padding_edge);
    const rect = rl.Rectangle.init(pos.x, pos.y, aspect_ratio.x * 200, aspect_ratio.y * 200);
    const color = rl.Color.fromHSV(11, 0.25, 1);

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

    _ = labelText2(r);
}

fn labelText2(r: *const Recipe) *const [3][]const u8 {
    var buf_recipe_coffee_weight: [4]u8 = undefined;
    const str_coffee: [:0]const u8 = std.fmt.bufPrintZ(&buf_recipe_coffee_weight, "{d}g", .{r.coffee_g}) catch |err| {
        utils.fatal("\nunable to convert []const u8 to [:0]const u8: {s}\n", .{@errorName(err)});
    };
    const values = [_][]const u8{ r.name, r.brewer, str_coffee };
    _ = values;
    var a = std.StringHashMap([]const u8).init(aapa_alloc);
    defer a.deinit();

    a.put(r.name, "asdf") catch |err| {
        utils.fatal("\nunable to put in hashmap with error: {s}\n", .{@errorName(err)});
    };
    const labels = [_][]const u8{ "asdf", "asdfasdf", "asdfsa" };
    // print("\nlabels: {s}\n", .{labels});
    // print("\nhashmap: {s}\n", .{a.get(r.name).?});
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
