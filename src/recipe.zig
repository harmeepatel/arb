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

const InternalEvent = struct {
    event_type: EventType,
    name: Legend,
    time: u16,
    name_note: ?[]const u8 = null,
    quantity: ?Quantity,
    duration: ?u16,
    range: ?u16 = null,
    note: ?[]const u8 = null,
};

pub const Event = struct {
    event_type: EventType,
    name: Legend,
    time: u16,
    name_note: ?[:0]const u8 = null,
    quantity: ?Quantity,
    duration: ?u16,
    range: ?u16 = null,
    note: ?[:0]const u8 = null,

    // pub fn initNormalEvent(name: Legend, time: u16, name_note: ?[]const u8, quantity: ?Quantity, duration: ?u16, range: ?u16, note: ?[]const u8) Event {
    pub fn initNormalEvent(event: InternalEvent) Event {
        return .{
            .event_type = .normal,
            .time = event.time,
            .name = event.name,
            .name_note = event.name_note,
            .quantity = event.quantity,
            .duration = event.duration,
            .range = event.range,
            .note = event.note,
        };
    }

    // pub fn initSmallEvent(name: Legend, time: u16, name_note: ?[]const u8, note: ?[]const u8) Event {
    pub fn initSmallEvent(event: InternalEvent) Event {
        return .{
            .event_type = .short,
            .name = event.name,
            .time = event.time,
            .name_note = event.name_note,
            .note = event.note,
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

const InternalRecipe = struct {
    name: []const u8,
    brewer: []const u8,
    grind: []const u8,
    filter: []const u8,
    coffee: u8,
    water_ml: u16,
    water_temp: u8,
    total_time: [2]u16,
    before_event: ?BeforeEvent = null,
    events: Events,
};

pub const Recipe = struct {
    name: [:0]const u8,
    brewer: [:0]const u8,
    grind: [:0]const u8,
    filter: [:0]const u8,
    coffee: u8,
    water_ml: u16,
    water_temp: u8,
    total_time: [2]u16,
    before_event: ?BeforeEvent = null,
    events: Events,

    pub fn init(alloc: std.mem.Allocator, json_recipe: []const u8) !Recipe {
        const parsed = try std.json.parseFromSlice(InternalRecipe, alloc, json_recipe, .{
            .allocate = .alloc_always,
            .ignore_unknown_fields = true,
        });
        return Recipe{
            .name = try alloc.dupeZ(u8, parsed.value.name),
            .brewer = try alloc.dupeZ(u8, parsed.value.brewer),
            .grind = try alloc.dupeZ(u8, parsed.value.grind),
            .filter = try alloc.dupeZ(u8, parsed.value.filter),
            .coffee = parsed.value.coffee,
            .water_ml = parsed.value.water_ml,
            .water_temp = parsed.value.water_temp,
            .total_time = parsed.value.total_time,
            .before_event = parsed.value.before_event,
            .events = parsed.value.events,
        };
    }
};
