#include <stdint.h>

#define FRAMEBUFFER 0x00010000u
#define VGA_BASE    0x10000000u
#define VGA_CTRL    (*(volatile uint32_t *)(VGA_BASE + 0x00))
#define VGA_STATUS  (*(volatile uint32_t *)(VGA_BASE + 0x04))

#define FRAME_WORDS (640u * 480u / 4u)

int main(void) {
    volatile uint32_t *fb = (volatile uint32_t *)FRAMEBUFFER;

    // Fill the complete 640x480 framebuffer with an RGB332 background.
    // Four 8-bit pixels are written per CPU store to keep initialization fast.
    const uint32_t background = 0x9F9F9F9Fu;
    for (uint32_t i = 0; i < FRAME_WORDS; ++i)
        fb[i] = background;

    // CTRL bit 0 = display enable; bit 1 = 10-FPS duck animation enable.
    VGA_CTRL = 0x00000003u;

    while (1)
        (void)VGA_STATUS;

    return 0;
}
