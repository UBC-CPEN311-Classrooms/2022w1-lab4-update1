inline void vga_plot(unsigned x, unsigned y, unsigned colour)
{
    volatile unsigned *vga = (volatile unsigned *) 0x00004000; 
    
    *vga = (y << 24 | x << 16 | colour);
}