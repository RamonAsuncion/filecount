const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    var buf: [1024]u8 = undefined;

    const args = std.os.argv;

    // check if user presses enter
    while (true) {
        const line = try stdin.readUntilDelimiterOrEof(&buf, '\n');
        // TODO: add this to a buffer then switch over args.
        if (line) |text| {
            std.debug.print("{s}\n", .{text});
        } else {
            break;
        }
    }

    const fs = std.fs.cwd();

    var total_lines: usize = 0;
    var total_words: usize = 0;
    var total_bytes: usize = 0;

    for (args[1..]) |arg| {
        const path: []const u8 = std.mem.span(arg);

        const file = fs.openFile(path, .{}) catch {
            try stdout.print("filecount: {s}: open: No such file or directory\n", .{path});
            continue;
        };
        defer file.close();

        var line_count: usize = 0;
        var word_count: usize = 0;
        var byte_count: usize = 0;

        const file_reader = file.reader();
        var word: bool = false;

        while (true) {
            const byte = file_reader.readByte() catch {
                break;
            };

            byte_count += 1;
            total_bytes += 1;

            if (byte == '\n') {
                line_count += 1;
                total_lines += 1;
            }

            if (std.ascii.isWhitespace(byte)) {
                if (word) {
                    word = false;
                }
            } else {
                if (!word) {
                    word_count += 1;
                    total_words += 1;
                    word = true;
                }
            }
        }
        try stdout.print("{d} {d} {d} {s}\n", .{ line_count, word_count, byte_count, path });
    }
    if (args.len > 2) {
        try stdout.print("{d} {d} {d} total\n", .{ total_lines, total_words, total_bytes });
    }
}
