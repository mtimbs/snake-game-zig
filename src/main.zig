const w4 = @import("wasm4.zig");
const std = @import("std");
const Snake = @import("snake.zig").Snake;
const Point = @import("snake.zig").Point;

var snake = Snake.init();
var fruit: Point = undefined;
const fruit_sprite = [16]u8{ 0x00, 0xa0, 0x02, 0x00, 0x0e, 0xf0, 0x36, 0x5c, 0xd6, 0x57, 0xd5, 0x57, 0x35, 0x5c, 0x0f, 0xf0 };
var frame_count: u32 = 0;
var previous_gamepad: u8 = 0;
var prng: std.rand.DefaultPrng = undefined;
var random: std.rand.Random = undefined;

fn rnd(max: i32) i32 {
    return random.intRangeLessThan(i32, 0, max);
}

export fn start() void {
    w4.PALETTE.* = .{
        0x0f052d,
        0x203671,
        0x36868f,
        0x5fc75d,
    };

    prng = std.rand.DefaultPrng.init(0);
    random = prng.random();
    fruit = Point.init(rnd(20), rnd(20));
}

fn input() void {
    const gamepad = w4.GAMEPAD1.*;
    const pressed_this_frame = gamepad & (gamepad ^ previous_gamepad);
    previous_gamepad = gamepad;

    if (pressed_this_frame & w4.BUTTON_UP != 0) {
        snake.up();
    }

    if (pressed_this_frame & w4.BUTTON_RIGHT != 0) {
        snake.right();
    }

    if (pressed_this_frame & w4.BUTTON_DOWN != 0) {
        snake.down();
    }

    if (pressed_this_frame & w4.BUTTON_LEFT != 0) {
        snake.left();
    }
}

export fn update() void {
    frame_count += 1;

    input();

    if (frame_count % 15 == 0) {
        snake.update();

        if (snake.killedItself()) {
            @panic("You ded fool");
            // TODO: Show some text and stop the game
        }

        if (snake.body.get(0).equals(fruit)) {
            const tail = snake.body.get(snake.body.len - 1);
            snake.body.append(Point.init(tail.x, tail.y)) catch @panic("couldn't grow snek");
            fruit.x = rnd(20);
            fruit.y = rnd(20);
        }
    }

    snake.draw();

    w4.DRAW_COLORS.* = 0x4320;
    w4.blit(&fruit_sprite, fruit.x * 8, fruit.y * 8, 8, 8, w4.BLIT_2BPP);
}
