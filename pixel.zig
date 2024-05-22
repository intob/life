const std = @import("std");
const c = @cImport({
    @cInclude("GL/glew.h");
    @cInclude("GLFW/glfw3.h");
});

const width = 800;
const height = 600;

pub fn main() !void {
    // Initialize GLFW
    if (c.glfwInit() == c.GLFW_FALSE) {
        std.log.err("Failed to initialize GLFW", .{});
        return error.GlfwInitFailed;
    }
    defer c.glfwTerminate();

    // Create a window
    const window = c.glfwCreateWindow(width, height, "Zig OpenGL Example", null, null);
    if (window == null) {
        std.log.err("Failed to create GLFW window", .{});
        return error.GlfwCreateWindowFailed;
    }
    defer c.glfwDestroyWindow(window);

    // Make the window's context current
    c.glfwMakeContextCurrent(window);

    // Initialize GLEW
    if (c.glewInit() != c.GLEW_OK) {
        std.log.err("Failed to initialize GLEW", .{});
        return error.GlewInitFailed;
    }

    // Set up viewport
    c.glViewport(0, 0, width, height);

    // Main loop
    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        // Clear the screen
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        // Generate random black and white pixels
        var y: c_int = 0;
        while (y < height) : (y += 10) {
            var x: c_int = 0;
            while (x < width) : (x += 10) {
                const color = if (std.crypto.random.int(u8) < 128) c.GL_WHITE else c.GL_BLACK;
                c.glColor3f(color, color, color);
                c.glRecti(x, y, x + 10, y + 10);
            }
        }

        // Swap front and back buffers
        c.glfwSwapBuffers(window);

        // Poll for events
        c.glfwPollEvents();
    }
}
