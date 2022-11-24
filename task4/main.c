volatile unsigned *vga = (volatile unsigned *) 0x00004000; /* VGA adapter base address */
#include "vga_plot.c"

unsigned char pixel_list[] = {
#include "../misc/pixels.txt"
};
unsigned num_pixels = sizeof(pixel_list)/2;

int main()
{
	//
}
