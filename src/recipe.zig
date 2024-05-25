const std = @import("std");

pub const Legend = enum {
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

pub const EventType = enum {
    normal,
    short,
};

pub const Quantity = packed struct(u16) {
    tare: bool = false,
    value: u15,
};

pub const Event = struct {
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

pub const Events = []Event;

pub const BeforeEvent = struct {
    event_type: EventType = .short,
    name: Legend,
};

pub const Recipe = struct {
    name: []const u8,
    brewer: []const u8,
    grind: []const u8,
    coffee: u8,
    water_ml: u16,
    water_temp: u8,
    total_time: [2]u16,
    before_event: ?BeforeEvent = null,
    events: Events,

    pub fn init(alloc: std.mem.Allocator, json_recipe: []const u8, recipe_buf: *Recipe) !void {
        const parsed = try std.json.parseFromSlice(Recipe, alloc, json_recipe, .{
            .allocate = .alloc_always,
            .ignore_unknown_fields = true,
        });
        // defer alloc.free(parsed);
        recipe_buf.* = parsed.value;
    }
};
