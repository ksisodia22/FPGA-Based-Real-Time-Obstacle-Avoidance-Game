# FPGA-Based-Real-Time-Obstacle-Avoidance-Game

## Overview

This project implements a simple car obstacle avoidance game on the Altera DE2-115 board using a Cyclone IV E FPGA. The game involves moving a car to avoid falling obstacles, with user inputs provided via push buttons and visual output displayed on a VGA screen. The project showcases the integration of hardware modules for debouncing, random obstacle generation, collision detection, and VGA signal generation.

## Table of Contents

1. [Preparation and Planning](#preparation-and-planning)
2. [Buttons and Position Array](#buttons-and-position-array)
3. [VGA Output](#vga-output)
4. [VGA Graphics Array](#vga-graphics-array)
5. [Pseudo Random Obstacle Generator](#pseudo-random-obstacle-generator)
6. [Obstacle Update Array](#obstacle-update-array)
7. [Collision Check and Game State Update](#collision-check-and-game-state-update)
8. [Game Generation](#game-generation)
9. [Future Improvements](#future-improvements)

## Preparation and Planning

The team identified nine major sections required for the final project:
1. Start Process / Begin Game
2. Take User Input
3. Update Car Position
4. Generate Pseudo-Random Array for Obstacle Array
5. Test Random Array for Criteria
6. Check for Collisions
7. Update Game State
8. Generate Display

## Buttons and Position Array

This module handles user inputs for moving the car left or right using the push buttons on the DE2-115 board. To mitigate the mechanical bouncing of the buttons, a debouncing mechanism is implemented. The debouncing code was adapted from [FPGA 4 Fun](http://www.fpga4fun.com/Debouncer2.html).

### Debouncing Code
```verilog
wire L_idle = (L_state==L_sync_1);
wire L_cnt_max = &L_cnt;
reg [15:0] R_cnt;
wire R_idle = (R_state==R_sync_1);
wire R_cnt_max = &R_cnt;

always @(posedge clk)
if(L_idle)
    L_cnt <= 0;
else begin
    L_cnt <= L_cnt + 16'd1;
    if(L_cnt_max) L_state <= ~L_state;
end

always @(posedge clk)
if(R_idle)
    R_cnt <= 0;
else begin
    R_cnt <=R_cnt + 16'd1;
    if(R_cnt_max) R_state <= ~R_state;
end

assign L_down = ~L_idle & L_cnt_max & ~L_state;
assign R_down = ~R_idle & R_cnt_max & ~R_state;

reg [0:3] Y1;
parameter [3:0] A=3'b001, B=3'b010, C=3'b100, D=3'b000;

always @ (posedge clk) begin
    case(Y1)
        A: if(L_down) begin
            out=B;
            Y1=B;
        end
        B: begin
            if (R_down) begin
                out=A;
                Y1=A;
            end
            if(L_down) begin
                out=C;
                Y1=C;
            end
        end
        C: if (R_down) begin
            out=B;
            Y1=B;
        end
        D: begin
            Y1=B;
            out=B;
        end
    endcase
end
endmodule
