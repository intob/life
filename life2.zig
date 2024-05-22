const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const rows: usize = 160;
    const cols: usize = 160;

    var matrix1 = try allocator.alloc(u4, rows * cols);
    var matrix2 = try allocator.alloc(u4, rows * cols);
    defer {
        allocator.free(matrix1);
        allocator.free(matrix2);
    }

    var current = &matrix1;
    var next = &matrix2;

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    for (current.*) |*cell| {
        cell.* = if (rand.boolean()) 1 else 0;
    }

    var rowstr = try allocator.alloc(u8, cols);
    defer allocator.free(rowstr);

    var g: u32 = 0;
    while (g < 100000) : (g += 1) {
        try print(&rowstr, current, rows, cols);
        gen(rows, cols, current, next);
        std.mem.swap(@TypeOf(current), &current, &next);
    }
}

fn print(rowstr: *[]u8, m: *const []u4, rows: usize, cols: usize) !void {
    try std.io.getStdOut().writeAll("\x1B[2J"); // clear screen
    try std.io.getStdOut().writeAll("\x1B[H"); // move cursor to top left corner
    var row: usize = 0;
    var col: usize = 0;
    while (row < rows) : (row += 1) {
        while (col < cols) : (col += 1) {
            if (m.*[row * cols + col] == 1) {
                rowstr.*[col] = 0x23;
            } else {
                rowstr.*[col] = 0x20;
            }
        }
        std.debug.print("{s}\n", .{rowstr.*});
        col = 0;
    }
}

fn gen(rows: usize, cols: usize, current: *[]u4, next: *[]u4) void {
    var pos: usize = 0;
    while (pos < rows * cols) : (pos += 1) {
        const row: i32 = @intCast(pos / cols);
        const col: i32 = @intCast(pos % cols);
        var alive_neighbors: u4 = 0;
        for ([_]i32{ -1, 0, 1 }) |dy| {
            for ([_]i32{ -1, 0, 1 }) |dx| {
                if (dy == 0 and dx == 0) continue;
                const y: i32 = row + dy;
                const x: i32 = col + dx;
                if (y < 0 or y >= rows or x < 0 or x >= cols) continue;
                const y_usize: usize = @intCast(y);
                const x_usize: usize = @intCast(x);
                if (current.*[y_usize * cols + x_usize] == 1) {
                    alive_neighbors += 1;
                }
            }
        }
        if (current.*[pos] == 1) {
            if (alive_neighbors < 2 or alive_neighbors > 3) {
                next.*[pos] = 0;
            } else {
                next.*[pos] = 1;
            }
        } else {
            if (alive_neighbors == 3) {
                next.*[pos] = 1;
            } else {
                next.*[pos] = 0;
            }
        }
    }
}
