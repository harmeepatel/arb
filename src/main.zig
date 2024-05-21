const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const rl = @import("raylib");
// necessary for now with stable zig 0.11.*

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var wasm_alloc = gpa.allocator();
// var wasm_alloc = std.heap.wasm_allocator;
var b: Recipe = undefined;

const image = bool;

const Legend = enum {
    bloom,
    break_crust,
    cap_on,
    distribute,
    draw_down,
    grind,
    invert,
    pour,
    press,
    swirl,
    stop_brew,
    stir,

    pub fn abbreviation(self: Legend) []const u8 {
        switch (self) {
            .bloom => return "B",
            .break_crust => return "BC",
            .cap_on => return "Ca",
            .distribute => return "Di",
            .draw_down => return "Dr",
            .grind => return "G",
            .invert => return "Iv",
            .pour => return "P",
            .press => return "Pr",
            .swirl => return "S",
            .stop_brew => return "SB",
            .stir => return "St",
        }
    }
};

const EventType = enum {
    normal,
    short,
};

const Quantity = packed struct(u16) {
    tare: bool = false,
    value: u15,
};

const Event = struct {
    event_type: EventType,
    name: Legend,
    time: u16,
    name_note: ?[]const u8 = null,
    quantity: ?Quantity,
    duration: ?u16,
    range: ?u16 = null,
    note: ?[]const u8 = null,

    pub fn initNormalEvent(name: Legend, time: u16, name_note: ?[]const u8, quantity: ?Quantity, duration: ?u16, range: ?u16, note: ?[]const u8) Event {
        return .{
            .event_type = .normal,
            .time = time,
            .name = name,
            .name_note = name_note,
            .quantity = quantity,
            .duration = duration,
            .range = range,
            .note = note,
        };
    }

    pub fn initSmallEvent(name: Legend, time: u16, name_note: ?[]const u8, note: ?[]const u8) Event {
        return .{
            .event_type = .short,
            .name = name,
            .time = time,
            .name_note = name_note,
            .note = note,
            .quantity = null,
            .duration = null,
            .range = null,
        };
    }
};

const Events = []Event;

const BeforeEvent = struct {
    event_type: EventType = .short,
    name: Legend,
};

const Recipe = struct {
    name: []const u8,
    brewer: []const u8,
    grind: []const u8,
    coffee: u8,
    water_ml: u16,
    water_temp: u8,
    total_time: [2]u16,
    before_event: ?BeforeEvent = null,
    events: Events,

    pub fn init(alloc: std.mem.Allocator, json_recipe: []const u8) !std.json.Parsed(Recipe) {
        const parsed = try std.json.parseFromSlice(Recipe, alloc, json_recipe, .{
            .allocate = .alloc_always,
            .ignore_unknown_fields = true,
        });

        return parsed;
    }
};

pub fn main() !void {
    const factor = 100;
    const screen_width = 16 * factor;
    const screen_heigt = 9 * factor;
    _ = rl.initWindow(screen_width, screen_heigt, "test");
    defer rl.closeWindow();

    const file = try std.fs.cwd().openFile("./data/recipe.json", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(wasm_alloc);
    var trimed_lines = std.ArrayList(u8).init(wasm_alloc);
    defer line.deinit();
    defer trimed_lines.deinit();

    var line_no: usize = 1;

    // var f = try ;
    // std.debug.print("{s}\n", .{f.?});
    while (reader.readUntilDelimiterArrayList(&line, '\n', 1024 * 4)) {
        // const a: []u8 = line.items;
        // const a = std.mem.trim(u8, &buf, " ");
        // _ = try trimed_lines.appendSlice(a);
        line_no += 1;
    } else |err| switch (err) {
        error.EndOfStream => {}, // Continue on
        else => return err, // Propagate error
    }
    std.debug.print("lines: {d}\n", .{line_no});
    std.debug.print("lines: {d}\n", .{line_no});
    // std.debug.print("start: {d} -- end: {d}\n", .{ buf_reader.start, buf_reader.end });
    // std.debug.print("res: {d}\n", .{res});

    const arr = try line.toOwnedSlice();
    for (arr, 0..) |l, idx| {
        std.debug.print("line[{d}]: {s}\n", .{ idx, l });
    }

    rl.setTargetFPS(1);
    while (!rl.windowShouldClose()) {
        const i = rl.genImagePerlinNoise(screen_width, screen_width, 0, 0, 20);
        defer rl.unloadImage(i);
        const t = rl.loadTextureFromImage(i);
        defer rl.unloadTexture(t);

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);
    }
}

export fn createImage(ptr: [*]const u8, len: usize) void {
    const json: []const u8 = ptr[0..len];
    const a = Recipe.init(wasm_alloc, json) catch {
        @panic("falied to initialize recipe");
    };
    defer a.deinit();

    _ = rl.initWindow(1920, 1080, "test");
    defer rl.closeWindow();
}

export fn allocBytes(len: usize) ?[*]u8 {
    return if (wasm_alloc.alloc(u8, len)) |slice| slice.ptr else |_| null;
}

export fn freeBytes(ptr: ?[*]const u8, len: usize) void {
    if (ptr) |valid_ptr| wasm_alloc.free(valid_ptr[0..len]);
}
