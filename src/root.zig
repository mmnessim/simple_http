const std = @import("std");
const ztring = @import("ztring");
const testing = std.testing;

const USERAGENT: []const u8 = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36";

pub fn GET(url: []const u8, alloc: std.mem.Allocator, headerBuffer: []u8, bodyBuffer: []u8) ![]const u8 {
    var client = std.http.Client{ .allocator = alloc };
    defer client.deinit();

    const uri = try std.Uri.parse(url);
    var req = try client.open(.GET, uri, .{ .server_header_buffer = headerBuffer, .headers = .{ .user_agent = .{ .override = USERAGENT } } });
    defer req.deinit();

    try req.send();
    try req.finish();
    try req.wait();

    std.debug.print("status={d}\n", .{req.response.status});

    const bodyLen = req.reader().readAll(bodyBuffer) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return err;
    };

    const result: []const u8 = bodyBuffer[0..bodyLen];
    return result;
}

pub fn POST(url: []const u8, reqBody: []const u8, alloc: std.mem.Allocator, headerBuffer: []u8, bodyBuffer: []u8) ![]const u8 {
    var client = std.http.Client{ .allocator = alloc };
    defer client.deinit();

    const uri = try std.Uri.parse(url);
    var req = client.open(.POST, uri, .{
        .server_header_buffer = headerBuffer,
        .headers = .{ .user_agent = .{ .override = USERAGENT }, .content_type = .{ .override = "text/plain" } },
    }) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return err;
    };
    defer req.deinit();

    req.transfer_encoding = .{ .content_length = reqBody.len };

    try req.send();
    try req.writer().writeAll(reqBody);
    try req.finish();
    try req.wait();

    std.debug.print("status={d}\n", .{req.response.status});

    const bodyLen = req.reader().readAll(bodyBuffer) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return err;
    };
    const result = bodyBuffer[0..bodyLen];
    return result;
}
