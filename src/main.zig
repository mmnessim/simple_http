const std = @import("std");
const ztring = @import("ztring");
const simple_http = @import("root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const baseURL = "https://api.chess.com/pub/player/";
    const username = "tenderllama";
    var buffer: [100]u8 = undefined;

    const fullURL = try ztring.concatString(baseURL, username, &buffer);

    var headerBuf: [1024 * 1024]u8 = undefined;
    var bodyBuf: [4096 * 1024]u8 = undefined;
    //const postBody = "Hello from Zig";

    const result = try simple_http.GET(fullURL, allocator, &headerBuf, &bodyBuf);
    std.debug.print("RESULT: {s}\n", .{result});
}

fn getLine(buffer: []u8) ![]const u8 {
    const stdin = std.io.getStdIn().reader();

    const line = try stdin.readUntilDelimiter(buffer, '\n');

    return line;
}
