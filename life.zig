const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const rows: usize = 60;
    const cols: usize = 100;

    var matrix1 = try allocator.alloc(u4, rows * cols);
    var matrix2 = try allocator.alloc(u4, rows * cols);
    defer allocator.free(matrix1);
    defer allocator.free(matrix2);

    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();

    var pos: usize = 0;
    while (pos < rows * cols) : (pos += 1) { // generate random initial state
        matrix1[pos] = rand.int(u4);
    }

    var current = &matrix1;
    var next = &matrix2;

    var g: u32 = 0;
    while (g < 1000) : (g += 1) {
        print(current, rows, cols); // TODO: possibly alternate
        gen(rows, cols, current, next);
        std.mem.swap(@TypeOf(current), &current, &next);
    }
}

fn print(m: *const []u4, rows: usize, cols: usize) void {
    var row: usize = 0;
    while (row < rows) : (row += 1) {
        const start: usize = row * cols;
        const end: usize = start + cols;
        for (m.*[start..end]) |_| {
            std.debug.print("#", .{});
        }
        std.debug.print("\n", .{});
    }
}

// TODO: optimise by only evaluating boundaries once
fn gen(rows: usize, cols: usize, current: *[]u4, next: *[]u4) void {
    var pos: usize = 0;
    while (pos < rows * cols) : (pos += 1) {
        const row = pos / cols;
        const col = pos % cols;

        var n: ?usize = null;
        if (row > 0) n = pos - cols;
        var e: ?usize = null;
        if (col < cols - 1) e = pos + 1;
        var s: ?usize = null;
        if (row < rows - 1) s = pos + cols;
        var w: ?usize = null;
        if (col > 0) w = pos - 1;
        var ne: ?usize = null;
        if (row > 0 and col < cols - 1) ne = e.? - cols;
        var se: ?usize = null;
        if (row < rows - 1 and col < cols - 1) se = e.? + cols;
        var sw: ?usize = null;
        if (row < rows - 1 and col > 0) sw = w.? + cols;
        var nw: ?usize = null;
        if (row > 0 and col > 0) nw = w.? - cols;

        var neighbours: u4 = 0;
        if (n != null and alive(current.*[n.?])) neighbours += 1;
        if (e != null and alive(current.*[e.?])) neighbours += 1;
        if (s != null and alive(current.*[s.?])) neighbours += 1;
        if (w != null and alive(current.*[w.?])) neighbours += 1;
        if (ne != null and alive(current.*[ne.?])) neighbours += 1;
        if (se != null and alive(current.*[se.?])) neighbours += 1;
        if (sw != null and alive(current.*[sw.?])) neighbours += 1;
        if (nw != null and alive(current.*[nw.?])) neighbours += 1;
        next.*[pos] = neighbours;
    }
}

fn alive(cell: u4) bool {
    if (cell > 1 and cell < 4) {
        return true;
    }
    return false;
}
