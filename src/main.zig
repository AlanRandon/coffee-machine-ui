const std = @import("std");
const Allocator = std.mem.Allocator;

const c = @cImport({
    @cInclude("gtk/gtk.h");
});

const State = struct {
    count: usize,
    increment: *c.GtkButton,
    label: *c.GtkLabel,
    allocator: Allocator,

    fn update(state: *State) void {
        var label: [32]u8 = undefined;
        const label_len = std.fmt.formatIntBuf(&label, state.count, 10, .lower, .{});
        if (label_len < label.len) {
            label[label_len] = 0;
        }

        _ = c.gtk_label_set_label(
            state.label,
            @ptrCast(label[0..label_len]),
        );
    }

    fn incrementClicked(state: *State) void {
        state.count += 1;
        state.update();
    }

    fn registerEvents(state: *State) void {
        _ = c.g_signal_connect_data(state.increment, "clicked", @ptrCast(&struct {
            fn clicked(_: *c.GtkButton, s: *State) callconv(.C) void {
                s.incrementClicked();
            }
        }.clicked), state, null, 0);
    }

    fn deinit(state: *State) void {
        state.allocator.destroy(state);
    }
};

fn activate(app: *c.GtkApplication, allocator: *Allocator) callconv(.C) void {
    const builder = c.gtk_builder_new_from_resource("/org/gtk/coffee-ui/builder.ui");
    const window = c.gtk_builder_get_object(builder, "window");

    const state = allocator.create(State) catch unreachable;
    state.* = State{
        .count = 0,
        .increment = @ptrCast(c.gtk_builder_get_object(builder, "increment_button")),
        .label = @ptrCast(c.gtk_builder_get_object(builder, "count")),
        .allocator = allocator.*,
    };

    _ = c.g_signal_connect_data(window, "destroy", @ptrCast(&struct {
        fn destroy(_: *c.GtkButton, s: *State) callconv(.C) void {
            s.deinit();
        }
    }.destroy), state, null, 0);

    state.update();
    state.registerEvents();

    c.gtk_window_set_application(@ptrCast(window), app);
    c.gtk_window_present(@ptrCast(window));
    c.g_object_unref(builder);
}

pub fn main() !void {
    var allocator = std.heap.c_allocator;

    {
        const data = @embedFile("resources");
        const gbytes = c.g_bytes_new_static(data.ptr, data.len);
        const resources = c.g_resource_new_from_data(gbytes, null);
        c.g_resources_register(resources);
    }

    const app = c.gtk_application_new("org.gtk.coffee-ui", c.G_APPLICATION_DEFAULT_FLAGS);
    _ = c.g_signal_connect_data(app, "activate", @ptrCast(&activate), @ptrCast(&allocator), null, 0);
    _ = c.g_signal_connect_data(app, "startup", @ptrCast(&struct {
        fn destroy(_: *c.GtkApplication, _: *anyopaque) callconv(.C) void {
            const css_provider = c.gtk_css_provider_new();
            defer c.g_object_unref(css_provider);

            const display = c.gdk_display_get_default();
            c.gtk_style_context_add_provider_for_display(display, @ptrCast(css_provider), c.GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);

            c.gtk_css_provider_load_from_resource(css_provider, "/org/gtk/coffee-ui/style.css");
        }
    }.destroy), null, null, 0);
    const status = c.g_application_run(@ptrCast(app), @intCast(std.os.argv.len), @ptrCast(std.os.argv.ptr));
    c.g_object_unref(app);

    std.process.exit(@intCast(status));
}
