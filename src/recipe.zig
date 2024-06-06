const std = @import("std");
const print = std.debug.print;
const utils = @import("utils.zig");

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

fn MakeRecipeDupeZ(comptime in: type) type {
    const StringZ = [:0]const u8;
    const String = []const u8;
    const RecipeFields = std.meta.fields(in);

    var fields: [RecipeFields.len]std.builtin.Type.StructField = undefined;
    for (RecipeFields, 0..RecipeFields.len) |Field, i| {
        if (Field.type == String) {
            Field.type = StringZ;
        }

        fields[i] = .{
            .name = Field.name,
            .type = Field.type,
            .default_value = null,
            .is_comptime = false,
            .alignment = 0,
        };
    }
    return @Type(.{
        .Struct = .{
            .layout = .auto,
            .fields = fields[0..],
            .decls = &[_]std.builtin.Type.Declaration{},
            .is_tuple = false,
        },
    });
}

pub const Recipe = struct {
    name: [:0]const u8,
    brewer: [:0]const u8,
    grind_size: [:0]const u8,
    filter: [:0]const u8,
    stirrer: [:0]const u8,
    coffee_g: u16,
    water_g: u16,
    water_temp_c: u8,
    total_time: [2]u16,
    before_event: ?BeforeEvent = null,
    events: Events,

    pub fn init(alloc: std.mem.Allocator, json_recipe: []const u8) !Recipe {
        const parsed = std.json.parseFromSlice(comptime MakeRecipeDupeZ(Recipe), alloc, json_recipe, .{
            .allocate = .alloc_always,
            .ignore_unknown_fields = false,
        }) catch |err| {
            utils.fatal("failed to parse json_recipe with error: \n{s}", .{@errorName(err)});
        };
        return Recipe{
            .name = try alloc.dupeZ(u8, parsed.value.name),
            .brewer = try alloc.dupeZ(u8, parsed.value.brewer),
            .grind_size = try alloc.dupeZ(u8, parsed.value.grind_size),
            .filter = try alloc.dupeZ(u8, parsed.value.filter),
            .stirrer = try alloc.dupeZ(u8, parsed.value.stirrer),
            .coffee_g = parsed.value.coffee_g,
            .water_g = parsed.value.water_g,
            .water_temp_c = parsed.value.water_temp_c,
            .total_time = parsed.value.total_time,
            .before_event = parsed.value.before_event,
            .events = parsed.value.events,
        };
    }
};
