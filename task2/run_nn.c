/*
 *
 *
 *
 *
 *
 *
 * WARNING
 *
 *
 * Much of this code has been modified from it's prior version.
 *
 * The prior version (visible in git history) was tested. This version has not been tested.
 *
 *
 *
 *
 *
 *
 */

// note: only **one** of the options below should be 1
// if multiples are set to 1, the topmost takes priority
// if all are set to 0, no acceleration is used (pure software)
#define DONE_TASK8 0  // add bias and optionally apply activation function
#define DONE_TASK7 0  // add on-chip SRAM
#define DONE_TASK6 0  // create dot product accelerator
#define DONE_TASK5 0  // create wordcopy accelerator



volatile unsigned *hex = (volatile unsigned *) 0x00001010; /* hex display PIO */
volatile unsigned *wordcopy_acc = (volatile unsigned *) 0x00001040; /* memory copy accelerator */
volatile unsigned *dotprod_acc  = (volatile unsigned *) 0x00001100; /* DOT product accelerator */
volatile unsigned *act_acc      = (volatile unsigned *) 0x00001200; /* DOT product + activation function accelerator */
volatile      int *vga          = (volatile      int *) 0x00004000; /* VGA adapter base address */
volatile      int *bank0        = (volatile      int *) 0x00006000; /* SRAM bank0 */
volatile      int *bank1        = (volatile      int *) 0x00007000; /* SRAM bank1 */

/* normally these would be contiguous but it's nice to know where they are for debugging */
volatile int *nn      = (volatile int *) 0x08000000; /* neural network biases and weights */
volatile int *input   = (volatile int *) 0x08800000; /* input image */
volatile int *l1_acts = (volatile int *) 0x08801000; /* activations of layer 1 */
volatile int *l2_acts = (volatile int *) 0x08802000; /* activations of layer 2 */
volatile int *l3_acts = (volatile int *) 0x08803000; /* activations of layer 3 (outputs) */


#include "../task4/vga_plot.c"
//#include "vga_plot.c"




#define L1_IN  784
#define L1_OUT 1000
#define L2_IN L1_OUT
#define L2_OUT 1000
#define L3_IN L2_OUT
#define L3_OUT 10
#define NPARAMS (L1_OUT + L1_IN * L1_OUT + L2_OUT + L2_IN * L2_OUT + L3_OUT + L3_IN * L3_OUT)



int hex7seg(unsigned d) {
    const unsigned digits[] = { 0x40,  0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00, 0x10 };
    return (d < 10) ? digits[d] : 0x3f;
}





// ----------------------------------------------------------------
// Two ways of copying memory

/* use our wordcopy accelerator; pointers must be word-aligned */
// TASK5, TASK6, TASK7, TASK8
void wordcopy_hw(volatile int *dst, volatile int *src, int n_words)
{
    *(wordcopy_acc + 1) = (unsigned) dst;
    *(wordcopy_acc + 2) = (unsigned) src;
    *(wordcopy_acc + 3) = (unsigned) n_words;
    *wordcopy_acc = 0; /* start */
    *wordcopy_acc; /* make sure the accelerator is finished */
}

// BASELINE
void wordcopy_sw( volatile int *dst, volatile int *src, int n_words )
{
    // software version of wordcopy()
    for( int i = 0; i < n_words; i++ ) {
        dst[i] = src[i];
    }
}

void wordcopy( volatile int *dst, volatile int *src, int n_words )
{
  #if ( DONE_TASK5 || DONE_TASK6 || DONE_TASK7 || DONE_TASK8 )
    wordcopy_hw( dst, src, n_words );
  #else
    wordcopy_sw( dst, src, n_words );
  #endif
}





// ----------------------------------------------------------------
// Two ways of computing dot product

// TASK6, TASK7
// use accelerator hardware to compute the dot product of w[i]*ifmap[i]
// this hardware must do the equivalent of function dotprod_sw()
int dotprod_hw(int n_in, volatile int *w, volatile int *ifmap)
{
    // computes using hardware for both task5 or task6
    // task5 uses DRAM
    // task6 uses on-chip SRAM (bank0, bank1, bank2, bank3)
    *(dotprod_acc + 2) = (unsigned) w;
    *(dotprod_acc + 3) = (unsigned) ifmap;
    *(dotprod_acc + 5) = (unsigned) n_in;
    *dotprod_acc = 0; /* start */
    return *dotprod_acc; /* make sure the accelerator is finished */
}

// BASELINE
// use software to compute the dot product of w[i]*ifmap[i]
int dotprod_sw(int n_in, volatile int *w, volatile int *ifmap)
{
        int sum = 0;
        for (unsigned i = 0; i < n_in; ++i) { /* Q16 dot product */
            sum += (int) (((long long) w[i] * (long long) ifmap[i]) >> 16);
        }
        return sum;
}



// ----------------------------------------------------------------

// BASELINE, TASK6 and TASK7:  compute dot products
// optionally use accelerator to compute dot product only
void apply_layer_dot(int n_in, int n_out, volatile int *b, volatile int *w, int use_relu, volatile int *ifmap, volatile int *ofmap)
{
    for (unsigned o = 0, wo = 0; o < n_out; ++o, wo += n_in) {
        int sum = b[o]; /* bias for the current output index */
      #if ( DONE_TASK6 || DONE_TASK7 )
        sum += dotprod_hw( n_in, &w[wo], ifmap );
      #else // BASELINE
        sum += dotprod_sw( n_in, &w[wo], ifmap );
      #endif
        if (use_relu) sum = (sum < 0) ? 0 : sum; /* ReLU activation */
        ofmap[o] = sum;
    }
}

// TASK8: use full accelerator to calculate dot product, bias and ReLU
// full hardware to compute dot product, apply bias, and apply optional activation function
void apply_layer_act(int n_in, int n_out, volatile int *b, volatile int *w, int use_relu, volatile int *ifmap, volatile int *ofmap)
{
    *(act_acc + 3) = (unsigned) ifmap;
    *(act_acc + 5) = (unsigned) n_in;
    *(act_acc + 7) = (unsigned) use_relu;
    for (unsigned o = 0, wo = 0; o < n_out; ++o, wo += n_in) {
        *(act_acc + 1) = (unsigned) (b + o);
        *(act_acc + 2) = (unsigned) (w + wo);
        *(act_acc + 4) = (unsigned) (ofmap + o);
        *act_acc = 0; /* start */
    }
    *act_acc; /* make sure the accelerator is finished */
}



// ----------------------------------------------------------------

int max_index(int n_in, volatile int *ifmap)
{
    int max_sofar = 0;
    for( int i = 1; i < n_in; ++i ) {
        if( ifmap[i] > ifmap[max_sofar] ) max_sofar = i;
    }
    return max_sofar;
}

// This is a new function. It is untested.
void display_image( volatile int *image, int rows, int cols, int min_pixel_value_q1616, int max_pixel_value_q1616 )
{
    unsigned x, y;
    unsigned scale_range = (max_pixel_value_q1616 - min_pixel_value_q1616 + 1)/256;
    for( y=0; y<rows; y++ ) {
        for( x=0; x<cols; x++ ) {
            // initial pixel values range from 0x0000 to 0xffff (between 0.0 and 0.99998474)
            // if you expect image values to exceed this range, you must adjust this formula
            unsigned pixel_q1616 = (unsigned)*image++;
            unsigned gray_pixel_8b = ((pixel_q1616 - min_pixel_value_q1616) / scale_range) & 0xff;
            vga_plot( x, y, gray_pixel_8b );
        }
    }
}



int main()
{
    *hex = 0x3f; /* display - */

    volatile int *l1_b = nn;                    /* layer 1 bias */
    volatile int *l1_w = l1_b + L1_OUT;         /* layer 1 weights */
    volatile int *l2_b = l1_w + L1_IN * L1_OUT; /* layer 2 bias */
    volatile int *l2_w = l2_b + L2_OUT;         /* layer 2 weights */
    volatile int *l3_b = l2_w + L2_IN * L2_OUT; /* layer 3 bias */
    volatile int *l3_w = l3_b + L3_OUT;         /* layer 3 weights */

    int result;

    // display input image on VGA screen
    // expect input pixels to be in the range [0x0000,0xFFFF]
    display_image( input, 28, 28, 0, 0xFFFF );

  #if DONE_TASK8
    // use on-chip SRAM (bank0,bank1) for faster performance
    // apply_layer_act() computes the dot product, bias, and the activation function in hardware with faster memory
    // to speed things up, data is copied into one bank of on-chip SRAM, then back and forth between the two banks
    wordcopy( bank0, input, L1_IN );
    apply_layer_act( L1_IN, L1_OUT, l1_b, l1_w, 1,   bank0, bank1   );
    apply_layer_act( L2_IN, L2_OUT, l2_b, l2_w, 1,   bank1, bank0   );
    apply_layer_act( L3_IN, L3_OUT, l3_b, l3_w, 0,   bank0, bank1   );
    result = max_index( L3_OUT, bank1 );

  #elif DONE_TASK7
    // use on-chip SRAM (bank0,bank1) for faster performance 
    // apply_layer_dot() computes the dot product for a row, TASK7 is hardware with faster memory
    // to speed things up, data is copied into one bank of on-chip SRAM, then back and forth between the two banks
    wordcopy( bank0, input, L1_IN );
    apply_layer_dot( L1_IN, L1_OUT, l1_b, l1_w, 1,   bank0, bank1   );
    apply_layer_dot( L2_IN, L2_OUT, l2_b, l2_w, 1,   bank1, bank0   );
    apply_layer_dot( L3_IN, L3_OUT, l3_b, l3_w, 0,   bank0, bank1   );
    result = max_index( L3_OUT, bank1 );

  #elif DONE_TASK6
    // apply_layer_dot() computes the dot product for a row, BASELINE is software, TASK6 is hardware
    // all data stays in SDRAM
    apply_layer_dot( L1_IN, L1_OUT, l1_b, l1_w, 1,   input, l1_acts );
    apply_layer_dot( L2_IN, L2_OUT, l2_b, l2_w, 1, l1_acts, l2_acts );
    apply_layer_dot( L3_IN, L3_OUT, l3_b, l3_w, 0, l2_acts, l3_acts );
    result = max_index( L3_OUT, l3_acts );

  #else /* DONE_TASK5 or baseline */
    // write code here to test wordcopy software versus wordcopy hardware
    // use something like: wordcopy( copy_to_here, input, L1_IN );
    //    where 'L1_IN' is the amount of data to copy from address 'input'
    result = 0; // use this to print "0" to indicate "error" on 7seg
    result = 1; // use this to print "1" to indicate "correct" on 7seg
    result = 10; // use this to print "-" on 7seg
  #endif

    *hex = hex7seg( result );
    return 0;
}
