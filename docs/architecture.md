# Architecture and implementation notes

## Clock domains

The FPGA wrapper accepts the 100 MHz Arty oscillator and creates:

- 50 MHz CPU/interconnect/register clock
- 25 MHz VGA pixel clock

The reset remains asserted until the MMCM reports `LOCKED` and the user reset button is released.

The SoC synchronizes the single-bit display/animation enables from 50 MHz to 25 MHz. VGA status counters and `video_active` are synchronized back to 50 MHz for safe register reads. The 6-bit animation frame index also crosses through a two-register synchronizer before entering the 25 MHz VGA logic.

## Framebuffer semantics

The CPU owns framebuffer writes through port A. VGA owns port B and uses a synchronous read. The framebuffer is exactly `640*480 = 307200` bytes; invalid RAM addresses are forced to zero.

The interconnect aligns write addresses to the containing 32-bit word and uses byte strobes, allowing SB/SH/SW operations while preserving the correct byte lanes.

For VGA reads, the controller presents the **next pixel** address to the synchronous RAM. The timing counters advance on the same clock edge. Therefore, after a rising edge, the RAM output corresponds to the new current visible pixel. During blanking the prefetch address is harmless because RGB is forced to black.

## Register bus

The CPU-facing side is a simple single-master native memory bus. VGA control registers are reached through an AXI4-Lite-style adapter. Because the CPU is the only native master, a compact FSM is sufficient.

The register block implements:

- independent AW and W acceptance
- write response
- independent AR acceptance
- read response
- byte strobes
- invalid-access `SLVERR`
- alignment checking for `FB_BASE`

## RGB format

The framebuffer format is RGB332:

```text
[7:5] Red
[4:2] Green
[1:0] Blue
```

The Arty/Pmod VGA wrapper expands each channel to four output bits using bit replication. The Pmod VGA performs the analog conversion to VGA levels.

## Reset and display disable

Reset clears the SoC control state. When display enable is deasserted, the VGA RGB output is black while synchronization continues according to the timing generator.
