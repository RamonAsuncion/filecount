const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const args = std.os.argv;

    if (args.len == 1) {
        try stdout.print("usage: filecount <file1> <file2>...\n", .{});
        return;
    }

    const fs = std.fs.cwd();
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

            if (byte == '\n') line_count += 1;

            if (std.ascii.isWhitespace(byte)) {
                if (word) {
                    word = false;
                }
            } else {
                if (!word) {
                    word_count += 1;
                    word = true;
                }
            }
        }

        try stdout.print("{d} {d} {d} {s}\n", .{ line_count, word_count, byte_count, path });
    }
}
