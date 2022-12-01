#include "vga_plot.c"

volatile unsigned *vga = (volatile unsigned *) 0x00004000; /* VGA adapter base address */

unsigned char pixel_list[] = {
#include "../misc/pixels.txt"
};
unsigned num_pixels = sizeof(pixel_list)/2;

void vga_plot(unsigned x, unsigned y, unsigned colour);

int main(){
	
	for(unsigned x = 0; x < 160; x++)
		for(unsigned y = 0; y < 120; y++)
			vga_plot(x, y, 0);
	
	for(int i = 0; i < num_pixels*2; i+=2){
		vga_plot(pixel_list[i], pixel_list[i+1], pixel_list[i] * 5 / 3 % 255);
	}
}