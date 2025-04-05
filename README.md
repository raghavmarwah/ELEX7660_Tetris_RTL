# Tetris on FPGA - DE10-Nano Edition 🎮

Welcome to **Tetris on FPGA**, a hardware-accelerate implementation of the classic arcade game, running entirely on the **Intel DE10-Nano** FPGA board! This project brings together digital logic design and embedded software development. It was created as part of the **BCIT ELEX 7660: Digital System Design** course.

[raghavmarwah.com/blog/tetris-on-fpga](https://raghavmarwah.com/blog/tetris-on-fpga)

---

## 🚀 Project Overview

This is a pure **SystemVerilog + C** implementation of Tetris using:

- 🧠 **RTL logic** for all game mechanics (piece movement, collision, locking, scoring, etc.)
- 🖥️ **NIOS II soft processor** for drawing the framebuffer to the LCD display
- 🎵 **Hardware audio module** that plays the Tetris melody on game over
- 🕹️ **Analog joystick + pushbuttons** for controls
- ⚡ **7-segment LED display** for score
- 📺 **ST7735S 128x128 LCD** as game display

---

## 🔧 Hardware Requirements

| Component              | Description                                      |
|------------------------|--------------------------------------------------|
| [DE10-Nano FPGA](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=167&No=1046)       | Intel Cyclone V SoC FPGA development board       |
| [TI EduBoosterPack](https://www.ti.com/tool/BOOSTXL-EDUMKII)   | LCD screen + analog joystick + pusbuttons   |
| Wires & Breadboard   | For connecting FPGA Board GPIO to the EduBoosterPack |

**Note:** BCIT provided a custom PCB featuring two rotary encoders and four 7-segment LED displays. The board connects to the DE10-Nano via the GPIO1 header and includes pin headers to interface directly with the TI EduBoosterPack.

---

## 📦 Software Tools

- Intel Quartus Prime
- Platform Designer (Qsys)
- NIOS II Software Build Tools (Eclipse)

---

## 🗂️ Important Files

```plaintext
├── adcinterface.sv           # Custom ADC interface for joystick input
├── tetris_grid.sv            # Game logic implemented as an FSM
├── tetris_top.sv             # Top-level SystemVerilog wrapper
├── tonegen.sv                # Melody playback generator (Tetris theme!)
├── grid_interface.sv         # Avalon-MM interface to expose grid to CPU
├── bin14_to_bcd4.sv          # Score converter to BCD for 7-segment LEDs
├── decode7.sv / decode2.sv   # Display decoders for 7-segment display
├── tetris.c                  # LCD framebuffer drawing code (via NIOS II)
├── image.h                   # Background image data (optional)
├── tetris.qsys               # Platform Designer file for generating HDL
├── tetris.qsf                # Pin assignments
```
