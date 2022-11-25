# Deep Neural Networks on FPGA

## Contents

* [Background](#background)
  * [Deep neural networks](#deep-neural-networks)
  * [Q16\.16 fixed point](#q1616-fixed-point)
* [Design](#design)
  * [Task 1: Tutorials](#task-1-tutorials)
  * [Task 2: PLL and SDRAM controller](#task-2-pll-and-sdram-controller)
  * [Task 3: Simulation](#task-3-simulation)
  * [Task 4: Wrapping the VGA core](#task-4-wrapping-the-vga-core)
  * [Task 5: A memory copy accelerator](#task-5-a-memory-copy-accelerator)
  * [Task 6: A dot product accelerator](#task-6-a-dot-product-accelerator)
  * [Task 7: A faster dot product accelerator](#task-7-a-faster-dot-product-accelerator)
  * [Optional Task 8: A complete neural network accelerator](#optional-task-8-the-complete-neural-network-accelerator)
* [Additional specifications](#additional-specifications)
  * [Avalon protocol variant](#avalon-protocol-variant)
  * [Memory map](#memory-map)
  * [Test inputs](#test-inputs)
  * [Common problems](#common-problems)
* [Deliverables and Evaluation](#deliverables-and-evaluation)
  * [Marks Breakdown](#marks-breakdown)
* [Autograder Marking Process](#autograder-marking-process)
  * [Autograder Marks](#autograder-marks)


## Background

In this lab, you will build a deep neural network accelerator for an embedded Nios II system. You will also learn how to interface with off-chip SDRAM, and how to use a PLL to generate clocks with specific properties.

The RTL designs you will write are simple and fairly straightforward. The challenge comes from the system-on-chip component: you will build an entire system with an embedded softcore CPU. This means that you need to understand and carefully implement the interconnect protocol — otherwise your system will not work.

Because the system as a whole is more complex than the systems we've built before, it will be _extra_ important to write extensive unit tests and carefully debug all the pieces of your design before you connect them together.

In this lab, it is much easier to debug if you can use the physical DE1-SoC board because the software to communicate with the processor (load executables, single-step debugging) uses a USB connection which we cannot emulate in ModelSim. This USB connection provides a JTAG interface to load executables,
run the debugger (eg, run, single-step, display register values), and inspect memory contents. The USB connection also provides the UART serial port
used by the printf() software function.  If you do not have a DE1-SoC board, please try to do the best you can -- you can still load executables
(cumbersome) but you will not have access to a printf() function.

### Deep neural networks

We will use a type of neural network called a multi-layer perceptron (MLP) to classify the MNIST hand-written digit dataset. That is, our MLP will take a 28×28-pixel greyscale image as input and determine which digit (0..9) this image corresponds to.

An MLP consists of several linear layers that first multiply the previous layer's outputs by a weight matrix and add a constant “bias” value to each output, and then apply a non-linear activation function to obtain the current layer's outputs (called activations). Our MLP will have a 784-pixel input (the 28×28-pixel image), two 1000-neuron hidden layers, and a 10-neuron output layer; the output neuron with the highest value will tell us which digit the network thinks it sees. For the activation function, we will use the rectified linear unit (ReLU), which maps all negative numbers to 0 and all positive numbers to themselves.

During inference, each layer computes _a'_ = ReLU(_W_·_a_+_b_), where _W_ is the weight matrix, _a_ is the vector of the prior layer's activations, _b_ is the bias vector, and _a'_ is the current layer's activation vector. You might find [3Blue1Brown's neural network video](https://www.youtube.com/watch?v=aircAruvnKk) an excellent introduction to how the math works.

Do not be discouraged by fancy terms like neural networks — you are essentially building an accelerator to do matrix-vector multiplication. Most of the challenge here comes from interacting with the off-chip SDRAM memory and correctly handling signals like _waitrequest_ and _readdatavalid_.

You don't need to know how these networks are trained, since we have trained the network for you and pre-formatted the images (see the contents of the `data` folder, and the [list of test inputs](#test-inputs)). If you are curious, however, you can look in `scripts/train.py` to see how we trained the MLP.



### Q16.16 fixed point

In this lab, we will use **signed Q16.16** fixed-point numbers to represent all biases, activations, weights, etc.

In Q16.16 format, a 32-bit signed integer is used to represent a number of  1/65536th units. That is, the lower 16 bits represent the fractional part, while the upper 16 bits represent the integral part. This is still in two's complement format, so the most-significant
bit can be thought of as the sign bit (1=negative, 0=non-negative), though that bit cannot be removed from the number.
You can find further details on the [Q format](https://en.wikipedia.org/wiki/Q_(number_format)).

Computations on Q16.16 are performed by doing the actual operation on the
32-bit quanitity as if the numbers were integers, and then adjusting the
fractional point in the result as required. Because the fractional point in the
Q16.16 format is _fixed_,  you sometimes have to shift the result to restore
the fractional point to the correct position (eg, after multiplication).  This
shift discards some data, so one may choose to either round or truncate.
Truncating is easiest, where the lower bits are simply discarded. Rounding is
not very difficult -- you essentially add 0.5 and then truncate.  For DNNs,
precise rounding is often not required, so this lab will simply use truncation.


### Timing constraints

In this lab, you will need to include _timing constraints_ to make sure Quartus meets our desired clock frequency. You can do this by adding the constraints file `settings/timing.sdc` to your Quartus project; it will be automatically used by the Timing Analyzer.



## Design

### Task 1: Tutorials

If you haven't already, install the Intel FPGA Monitor Program from [Intel's University Program site](https://fpgacademy.org/tools.html).
You should be using version 18.1 of the FPGA Monitor tool.

Complete the following tutorials on Intel's DE boards tutorial. (The original site is at ftp://ftp.intel.com/Pub/fpgaup/pub/Intel_Material/18.1/Tutorials/).

- [Introduction to the Intel Nios II Soft Processor](tutorials/Nios2_introduction.pdf)
- [Introduction to the Platform Designer Tool](tutorials/Introduction_to_the_Qsys_Tool.pdf)
- [Intel FPGA Monitor Program Tutorial for Nios II](tutorials/Intel_FPGA_Monitor_Program_NiosII.pdf)

These tutorials describe how to build a Nios II-based SoC system, how to add
components that hang off the Avalon on-chip interconnect, and how to run
program on the Nios II core when you have a physical FPGA.

Because of changes to tool versions over the years, pay attention to the following differences:

- _Platform Designer_ used to be called _Qsys_.
- You may need to use the _Nios II processor_, not the _Nios II Classic_ (which may be gone).
- Only the _Nios II/e_ and _Nios II/f_ may be available in Platform Designer; use the _II/e_.
- The processor instance name may slightly different (contains _gen_ instead of _qsys_).
- The processor interface beginning with _jtag_ may now start with _debug_. Everything else is the same, though: there is still a reset interface and a memory-mapped servant interface.
- The reset polarity of some components may have changed. The toplevel is still active-low, though, so you don't need to change anything.
- The IP variation file you need to import into Quartus may have a `.qsys` extension, not `.qip`.
- The Monitor-generated `makefile` is buggy in 18.1 because target names are capitalized incorrectly — so you must add the following lines to it:
```
compile: COMPILE
clean: CLEAN
```
- Also in the `makefile`, find the line below:
```
LDFLAGS   := $(patsubst ...
```
and change it to:
```
LDFLAGS   := -mno-hw-mul -mno-hw-div $(patsubst ...
```

If your tutorial does not work, carefully check every step. **It's easy to miss a small part and then wonder why absolutely nothing works.**

You might also find it useful to refer to the following documents:
- [Avalon Interface Specifications](manuals/mnl_avalon_spec.pdf) (only sections 1–3 are relevant to us)
- [Nios II Processor Reference Guide](manuals/n2cpu-nii5v1gen2.pdf)
- [Nios II Software Developer Handbook](manuals/n2sw_nii5v2gen2-19-1.pdf)
- [Nios II Instruction Set Reference](manuals/n2cpu-nii51017.pdf)
- [Platform Designer User Guide](manuals/ug-qpp-platform-designer-19-1-683609-704996.pdf)

Note that the Avalon memory-mapped spec includes many signals, but you
generally only need to connect the subset you are using. In the rest of this
lab, the module templates we provided to get you started specify the set of
wires you actually need to connect.

Task 1 has no deliverable files, but you need to understand how to build and
debug an embedded system for the remainder of the lab.


### Task 2: PLL and SDRAM controller

Now, we will create a Nios II system that accesses the external SDRAM on your
DE1-SoC board. First, create a Nios II system using Platform Designer, as
above, except called `dnn_accel_system`. Include a JTAG module as well as a
32KB on-chip instruction memory; both should be connected to the instruction
and data masters. For the CPU, set the reset and exception vectors to the on-chip memory, at
the default offsets of 0x0 and 0x20. (This type of vector is a region of memory where we place a stub of 
instructions that is executed upon reset or when receiving an interrupt; it's not the same as an
vector in algebra. The vectors are very small, so there is only enough space to do something critical,
like perhaps immediately disabling further interrupts or flushing the instruction cache
and then jumping to a new location in memory where the rest of the instructions are stored.)

Refer to the [memory map](#memory-map) for the address ranges; you will add more components in the rest of the lab.

#### PLL

Next, add a phase-locked loop (PLL) IP to your system. Set up your PLL to have a 50MHz reference clock and two output clocks:

- `outclk0`, a 50MHz clock with a phase shift of 0ps, which will drive most of our design
- `outclk1`, a 50MHz clock with a phase shift of -3000ps, which will connect to the SDRAM chip (this accounts for things like the wiring between the FPGA and the SDRAM). **Note:** when you are using ModelSim (and not the physical FPGA board), enter a phase shift of 0ps for `outclk1`.

Also, enable the PLL locked output. Leave all other settings at their default values.

In Platform Designer, export `outclk1` as `sdram_clk` and the `locked` signal
as `pll_locked`. Connect the `refclk` input of the PLL to the default clock
source (`clk_0.clk`) and the `reset` input to the PLL to the default reset
source (`clk_0.clk_reset`). **Do not connect the PLL's reset to the debug
master — otherwise your system will lose the clock every time the FPGA Monitor
Program tries to reset your CPU!** Connect `outclk0` as the clock input to all
other modules except for `clk_0` — this includes the CPU, the SDRAM controller,
and all other modules you will add later.

#### SDRAM controller

Next, add an SDRAM controller to your system. 
While doing the task below, you might also wish to consult the [Intel tutorial for using the SDRAM](tutorials/Using_the_SDRAM.pdf).


The DE1-SoC SDRAM chip is has a total capacity of 64MBytes, arranged internally as 8M x 16b x 4 banks.
To match the board and SDRAM specifications, you will need to use the following settings when generating the controller:

|  parameter   |   setting  |
| ------------ | ---------- |
| data width   | 16 bits    |
| row width    | 13 bits    |
| column width | 10 bits    |
| refresh      | 7.8125µs   |
| t_rp         | 15.0ns     |
| t_rcd        | 15.0ns     |
| t_ac         | 5.4ns      |

Also activate the _Include functional memory model in the system testbench_ box. Leave all other settings at their default values.

After adding it to your system, double-click on the Base address and enter the
value 0x08000000. The End address should automatically change to 0x0dffffff,
indicating a capacity of 64MB.  Export the `wire` conduit interface of the
controller using the name `sdram`; these are the signals you will connect to the FPGA pins
that go to the off-chip SDRAM.

Note that the CPU's instruction master **should not** be connected to the SDRAM
controller; we will only read instructions from on-chip memory.

#### Output PIO

Finally, add a parallel I/O (PIO) module with a 7-bit output port and reset value 0x7f. Export this port as `hex` — we will use it to display the recognized digit.

#### Generating the testbench

After you generate the HDL in Platform Designer as in the tutorials, navigate to _Generate&rarr;Generate Testbench System_. This will generate a funtional model for the SDRAM, which you will need for simulation.

#### The rest

We have provided a toplevel `task2.sv` for you, which instantiates your system and connects it to the SDRAM and the 7-segment display. We have also provided `task5/run_nn.c`, the C file you will use to test your system. (Isn't that refreshing?)

**Using a real DE1-SoC only:** After compiling and loading the program, you will need to download the neural network's weights and an input image to the off-chip memory. You can do this in the FPGA Monitor Program by choosing _Actions&rarr;Load file into memory_. Specifically, load the following as _binary files_:

- `nn.bin` at address 0x08000000 (this will take a bit of time)
- one of the test images (e.g., `test_00.bin`) at address 0x08800000 (this is quick)

Finally, you can run the file to evaluate the neural network on the input image by running the program. Keep in mind that the generated Nios II processor is _very_ slow,

If you do not have a real DE1-SoC board, see Task 3 below for simulation instructions.

This task has no deliverables.

#### Tips

You can use `xxd nn.bin | less` on Mac/Linux or `format-hex nn.bin | out-host -paging` in Windows Powershell to examine binary files, and check that you loaded them correctly under the _Memory_ tab of the FPGA Monitor Program. Note that the files themselves are in _little-endian_ byte order but both `xxd` and `format-hex` show them as _big-endian_ while the Monitor shows them as _little-endian_.

Don't accidentally connect the debug reset to the PLL. If you do, the Monitor program will reset the PLL (and lose all clocks) every time it tries to reset the CPU, and you will never be able to run anything.


### Task 3: Simulation

#### Nios II system

To simulate the system in ModelSim, you will need to add the following files to your ModelSim project:

- `dnn_accel_system/simulation/submodules/*.v`
- `dnn_accel_system/simulation/submodules/*.sv`
- `dnn_accel_system/simulation/dnn_accel_system.v`

(where `dnn_accel_system` is whatever you told Platform Designer to call the generated system).


You will also need to copy these files into the directory where you are simulating:

- `dnn_accel_system/simulation/submodules/*.hex`

These are memory image files for all the CPU internal memories (e.g., register file) as well as the main memory you created.

For simulation, you will also want to tell ModelSim to use the `altera_mf_ver` library, and `cyclonev_ver`, `altera_ver`, and `altera_lnsim_ver` for netlist simulation.

When you simulate your design, you may see a large number of warnings. Some of them are due to the Platform Designer being sloppy:

- Some warnings in `dnn_accel_system.v` about missing connections for some JTAG ports. We will not be using these in simulation so we don't need to worry about it.
- Lots of warnings in `dnn_accel_system_nios2_gen2_cpu.v` about missing memory block connections, such as `wren_b`, `rden_a`, etc. This is because the generated Nios II CPU uses embedded memories for things like the register file, and does not connect some of the ports. (It works fine because the instantiation parameters configure the memory so that these ports are not used inside, but ModelSim does not know about that.) You may ignore those warnings.
- A few warnings about `DONTCARE` and Stratix devices. Ours is a Cyclone V FPGA, so we don't care.

Be sure to go through the warnings and make sure that none of them refer to **your** modules. It's easy to miss important issues in the sea of spurious warnings raised by the generated system and spend hours upon hours debugging.

Write a testbench that provides clock and reset, and simulate the system. You will find that not very much interesting is happening. Look at the signals `nios2_gen2_0_instruction_master_address`, `nios2_gen2_0_instruction_master_readdata`, and `nios2_gen2_0_instruction_master_read` — these connect to the on-chip Avalon interconnect to read instructions from the on-chip memory.

To make life a little more interesting, open the FPGA Monitor Program and write a short program that sets the LEDs to some value. Once the program is compiled, select _Actions &rarr; Convert Program to Hex File_; this will create an image of the program memory you can load in simulation. Replace the `dnn_accel_system_onchip_memory2_0.hex` with this file (alternatively, you can re-generate the memory with an initalization file and re-synthesize, but that takes longer).

Here is an example of such a program in Nios II assembly:

```assembly
main:
    movui r2, 0xaa
    movui r3, <led address here>
    stwio r2, 0(r3)
loop:
    beq zero, zero, loop
```

This tells the CPU to write 0xaa to the memory address where your LED module is mapped. If you did the Platform Designer tutorial correctly and followed the [Memory Map](#memory-map), you should see the `leds` bus in the waveforms change to `10101010` some cycles after the CPU was reset.

Now look again at the signals `nios2_gen2_0_instruction_master_address`, `nios2_gen2_0_instruction_master_readdata`, and `nios2_gen2_0_instruction_master_read`. You should find that the CPU reads addresses four sequential address (4-byte stride), and gets stuck at the `beq` instruction (our infinite loop). You can also observe the `*_data_master_*` signals, and see the moment where 0xaa is written to the LED address. This is also a good opportunity to confirm your understanding of how the Avalon master-servant interface works, including our good friend `waitrequest`.

#### SDRAM

In simulations, we need a way to simulate the DRAM module in the testbench and connect it to the DUT. Luckily Platform Designer provides a generic SDRAM simulation model, which you can use as follows:

1. When generating the processor system for simulation, make sure the PLL is configured such that `outclk1` uses a phase shift of 0ps.
2. When generating the SDRAM controller, make sure you enable “Include a functional memory model in the system testbench”
3. In addition to generating the system hardware (as usual), also generate a testbench for the system, which will include the SDRAM simulation model: _Generate&rarr;Generate Testbench System_.
4. The SDRAM simulation model can now be found at <your project dir>/<system name>/testbench/<system name>_tb/simulation/submodules/altera_sdram_partner_module.v
5. An example testbench that instantiates the SDRAM simulation model is found at <your project dir>/<system name>/testbench/<system name>_tb/simulation/<system_name>_tb.v
6. In simulations, the DRAM will be initialized from the file “altera_sdram_partner_module.dat” in the simulation directory. This is just a `$readmem`-readable file. You can overwrite it with your own.

We have provided `.dat` versions of the `.bin` files for the neural network model and the test images. Before you can use them, however, you need to change the offset within the SDRAM to where you want to store the data — this is the line that begins with `@`. Provided memory regions don't overlap, you can concatenate several of these files together; this may be useful to switch among different inputs quickly.

In general, to convert a binary file to format suitable for `$readmemh()`, you can run
```
objcopy -I binary -O verilog --verilog-data-width 2 test_00.bin out.v
```
(this requires a very recent version of `bintools`).


#### Debugging the NIOS program in simulation

When using a physical board, the FPGA Monitor Program has some debugging
features that you can use to step through the code and examine registers.

Unfortunately, you can’t use the Intel FPGA Monitor Program in simulation, but you can gather similar information from using ModelSim:

- Reading the register file: You can view the register file of the NIOS by going to _Windows&rarr;Memory List_ and selecting the instance `*/nios2_gen2_0/cpu/*cpu_register_bank_a/*/mem_data`
- Viewing the current instruction: `*/dut/nios2_gen2_0/i_readdata` is the data being sent from the on-chip instruction memory to the CPU. Decode these binary values based on the
[Nios II Instruction Set Reference](manuals/n2cpu-nii51017.pdf).

Note that ModelSim can do all of this with the RTL version of your solution.
You do not need to create testbenches and simulate the post-synthesized netlist
of the entire processor system.

Here is a program to read through the SDRAM and write each value to the hex output, to make sure that both memories are being accessed properly and are initialized correctly:

```assembly
main:
    movia r3, 0x00001010
    movia r4, 0x08000000
    movui r2, 0x00
    stw r2, 0(r3)
loop:
    addi r4, r4, 1
    ldbio r5, 0(r4)
    stw r5, 0(r3)
    beq zero, zero, loop
```

Note that you should not hope to run the DNN inference task to completion in simulation — it's just way too slow. Instead, you will have to figure out the first few output activations and monitor the relevant DRAM region to see what is happening.

Task 3 has no deliverables.

This GitHub link has additional tips on [SoC simulation](http://www.github.com/UBC-CPEN311-Classrooms/soc-simulation).


### Task 4: Wrapping the VGA core

Your objective here is to wrap the VGA core as an Avalon memory-mapped
interface servant, and integrate it in your Nios II system. A template Verilog
file is provided in `vga_avalon.sv`.

First, you will want to read a tutorial on how to create a new component for the computer system:
- [Making Platform Designer Components](tutorials/making_qsys_components.pdf)

The VGA adapter provided with this lab has been modified to output 8b grayscale
instead of 3b colour.  It is untested, so you may need to ask for help on Piazza.

The module you are to write will follow a very simple write-only interface.
Whenever address offset 0 is written and the coordinates are within screen
boundaries, you should send **exactly one pixel plot event** to the VGA core.
(If the coordinates are outside of the screen, the write should be ignored.)

The write request consists of a single 32-bit word with address offset 0, with
the following bit encoding:

| word offset | bits   | meaning                           |
| ---- | ------ | --------------------------------- |
|   0  | 30..24 | y coordinate (7 bits)             |
|   0  | 23..16 | x coordinate (8 bits)             |
|   0  | 7..0   | brightness (0=black, 255=white)   |

As usual, the top-left corner corresponds to coordinates (0,0). Your Avalon
module should ignore read requests as well as writes to locations other than
offset 0. 

Refer to the [memory map](#memory-map) for this accelerator's address range.

When you add your VGA component to the IP catalog, you will want to use a
conduit interface and export the VGA wires (`VGA_R`, `VGA_G`, `VGA_B`,
`VGA_HS`, `VGA_VS`, and `VGA_CLK`). When adding this component to your design,
use name the export `vga`.  Your top level should connect them to the
board-level VGA signals as usual.

The testbench goes in `tb_vga_avalon.sv` as usual. Again, it will not include
the entire Nios II system, but rather interact with your module directly. We
will also not include the VGA modules when checking your testbench for
coverage, so you will have to create a mock VGA adapter in `tb_vga_avalon.sv`
or another `tb_*.sv` file.

Next, complete `vga_plot.c`, which provides a C interface to your VGA module.
As before, it should implement only `vga_plot()`, should not include any
libraries, and should not implement any other functions such as `main()`.

In a separate file `main.c`, you should `#include` the contents of `vga_plot.c`
and add the function `main()`.  In the `misc` folder you will find a file
called `pixels.txt`, which you should also `#include` in main.c as the
initializing values of an array.  The contents are a list of (_x_,_y_) pixel
coordinates for an image.  Initially, write a function to draw all of these pixels in
white by repeatedly calling `vga_plot()` and fill the background (unlisted
pixels) with black. Next, modify the function to convert the image to shades of gray (instead of white)
using some clever transform. For example, you can use a weighted averaging scheme where
each pixel has eight immediate neighbours and sixteen
secondary neighbours; you can use compute a pixel brightness based on whether
its neighbour pixels are set, weighing closer pixels more heavily. The
weighting scheme below is one possibility, representing a total weight of 100,
that can be applied to a pixel located
at the center (0,0) by consulting pixels +/- 1 or 2 rows/columns away:

|   |-2-| -1| 0  |+1 |+2 |
|---|---|---|----|---|---|
|-2 | 1 | 2 |  4 | 2 | 1 |
|-1 | 2 | 4 |  8 | 4 | 2 |
| 0 | 4 | 8 | 16 | 8 | 4 |
|+1 | 2 | 4 |  8 | 4 | 2 |
|+2 | 1 | 2 |  4 | 2 | 1 |

The precise method you use to produce the grayscale is not important, but try to
use the full range of values from 0 to 255.

To demo this task, you will have to load your Nios II system on your board, and
then load C code that produces this image. There are nearly 2,000 pixels, so if
you are not somewhat careful you might run out of memory: make sure you encode
the pixel coordinates as bytes (`unsigned char`) rather than full integers.


### Task 5: A memory copy accelerator

Design an accelerator that will read a block of data from one range of
addresses in memory and write them to another.  This accelerator will be
implemented as an Avalon IP component. Like the VGA wrapper, this component
will use a memory-mapped Avalon **servant interface** to accept parameters from
the CPU. In addition, the component will use a **master interface** to be able
to read/write the SDRAM.

This capability is often called DMA copy.  The purpose is to do the memory
transfer without involving the CPU, which presumably could be doing something
more interesting in parallel.

To start the copying process, the processor will first set up the transfer by
writing the byte address of the destination range to word offset 1 in the
accelerator's address range, the source byte address to word offset 2, and the
number of 32-bit words to copy to word offset 3. Next, the CPU will write any
value to word offset 0 to start the copy process. Finally, the CPU will read
offset 0 to make sure the copy process has finished. In a nutshell, the Avalon
servant interface will use these offsets:

| word offset |                       meaning                       |
| ---- | --------------------------------------------------- |
|   0  | write: starts wordcopy; read: stalls until finished |
|   1  | destination byte address                            |
|   2  | source byte address                                 |
|   3  | number of 32-bit words to copy                      |

Values written to offsets 1, 2 or 3 are only changed by host writes over the
servant port, not by ongoing progress of the wordcopy hardware device.  That
is, the user should be able to change only the destination address to make
multiple copies of the same source data, and so on.  The value returned when
reading offset 0 is undefined; reading this is used to stall the host, not
provide data.

Note that your copy accelerator is copying multiple words of data, where one
word contains 4 bytes.  All of the pointers will be byte addresses, but they
will be aligned on 32-bit boundaries (i.e., your core does not need to handle
unaligned accesses). Conveniently, the SDRAM controller also operates with byte
addresses. The `run_nn.c` file contains some code you can run to test your
accelerator.

Refer to the [memory map](#memory-map) for this accelerator's address range.

Make sure you understand the functions of _readdatavalid_ and _waitrequest_
that are part of the master interface; they are documented in the Avalon spec.
In particular, the SDRAM controller may not respond to read requests
immediately — for example, it could be busy refreshing the DRAM or opening a
new row — and it might not be able to accept request all of the time, so you
will have to ensure that you don't read bogus data and don't drop requests on
the floor. (Conversely, observe that there is no _readdatavalid_ on your
module's servant interface.)

Also note how the CPU ensures the copy process has finished: it _reads_ offset
0 in your device's address range. This means that you must arrange for this
access to _stall_ until the copy is complete. Make sure you understand how
_waitrequest_ works. Also, your accelerator must be able to handle repeated
requests, so make sure it does not lock up after handling one request.

You will find the module skeleton in `wordcopy.sv`, and your RTL testsuite will
go in `tb_rtl_wordcopy.sv`. Note that you may have to mock any modules required
to thoroughly test your design, including the SDRAM controller Avalon
interface. You **do not** need to mock the actual SDRAM protocol, just the
interface to the controller.

To test `task5` at the highest level, you will need to write a short C program
that has an initialized region of memory, and then uses the `wordcopy()`
software function to start the DMA copy operation. The initialized region of
memory can be a static array in C, or it can be computed on the fly (eg, a
constant value, or a count, or pseudorandom numbers, etc).

**Note:** although you are not submitting a SYN testbench for this task, the
autograder will still synthesize your RTL and run it through the AG testbench.

**Note:** this task teaches you how to build an Avalon servant component. You
will not re-use the component again in future tasks.

Fun fact: a slightly more sophisticated version of this accelerator (i.e., one
that supports unaligned accesses and bitmasks) is called a _blitter_. Blitter
hardware was used to accelerate graphics processing, originally in the Xerox
Alto computer and later in the Commodore Amiga and arcade games.


#### Task 5.5: Creating a printf-equivalent for ModelSim debugging

This optional task is only for advanced students and worth zero marks.

The goal of this task is to help students that do not have a physical DE1-SoC
boards with debugging. To do this, you will create a printf-equivalent function
to aid debugging when no physical board is available. There is no worry about
plagiarism here -- several students can collaborate on this. A dedicated Piazza
subfolder has been created to discuss this.

Below, the basics will be outlined, but it is not a guaranteed approach. We
need more precise instructions to add to the lab. There is no credit for this
optional task.

1. Make sure the `sprintf()` function works in C -- it works exactly like `printf()`, except it writes the output to a character array in memory pointed to by the first argument of the function; the remaining arguments follow the `printf()` format. You probably need a physical DE1-SoC board.
2. Design an Avalon IP servant module called `vprintf` that accepts byte-writes. For each byte written, it should print the ASCII character, eg using `$display`. This code will be non-synthesizable, but it should be easily simulated in ModelSim. The Verilog can either try to print each ASCII character one at a time as it is received, or you can store the characters in an array and then print all of them at once when the end-of-string 0 is written.
3. Write a wrapper function called `vprintf()` that has the same arguments as `printf()`. It should emulate `printf()` by (a) using `sprintf()` to write the output string to a buffer, and then (b) iterate over every character in the buffer and write it character-by-character to the Avalon IP `vprintf` device. When writing a single byte, this should trigger Veriog to print that new character in ModelSim using `$display`.
4. Write instructions in this Markdown file (`README.md`) and check it in to your repository.
5. Post solution to Piazza for all to see.


### Task 6: A dot product accelerator

In this task, you will design an accelerator core to compute dot products using Q16.16 calculations. This computes a vector-vector dot
product _w_·_a_ in hardware. In software, this task will add a bias _b_, and optionally apply the ReLU activation function to the result.
Like `wordcopy`, the accelerator will have both servant and master Avalon interfaces.

In previous labs, hardware modules directly received argument values as input signals. Instead, this DNN accelerator will accept memory addresses as direct arguments, but will then need to read the values (inputs, weights, etc) from memory over the Avalon master interface.

To make use of the accelerator, you must modify the `run_nn.c` software to use the accelerator instead of using CPU instructions. You can do this by 
changing the `#define` values to to run the appropriate software for Task 5.

To set up the computation, the CPU will write addresses of the weight matrix, input activations, and the input activation vector length to the following word offsets in your component's address range:

| word offset |                       meaning                                  |
| ---- | -------------------------------------------------------------- |
|   0  | write: starts accelerator; read: stalls and provides result    |
|   1  | _reserved_                                                     |
|   2  | weight matrix byte address                                     |
|   3  | input activations vector byte address                          |
|   4  | _reserved_                                                     |
|   5  | input activations vector length                                |
|   6  | _reserved_                                                     |
|   7  | _reserved_                                                     |

It will also write  any value to offset 0 to start the computation.  Reading
offset 0 produces the result of the dot product.  As with the word copy
accelerator, you must use _waitrequest_ appropriately to stall reading of
the result at offset 0 until the dot product computation is finished.

Your component must handle multiple requests; otherwise you won't be able to use it repeatedly to compute the full matrix-vector product. If offsets 1–7 are not changed between two writes to offset 0, they must keep their previous values; for example, the user should be able to set the input activations address and the input activations vector length once and make several requests to your component by changing the weight address and writing the offset 0 to start.

All weights, biases, and activations are in **signed Q16.16 fixed point**. Make sure you account for this appropriately when multiplying numbers.

You will find the module skeleton in `dot.sv`, and your RTL testsuite will go in `tb_rtl_dot.sv`. Note that you will have to mock up any modules required to thoroughly test your design, including the SDRAM controller interface. The `run_nn.c` file provided in Task 2 already contains a function that uses your accelerator to compute a matrix-vector product. While it has been pre-written, it has been heavily modified since it was last tested.

To test this task, you should provide different input images and run the NN computation to completion until it produces a result. Verify the result of your system by writing a dedicated software-only version on your PC in C or Python.

**Note:** although you are not submitting a SYN testbench for this task, we will still synthesize your RTL and run it through our own testbench.


### Task 7: A faster dot product accelerator

In this task, you will optimize your dot product accelerator to reuse fetched
input activations, and get a flavour of how a computer architect thinks.

When designing a high-performance, energy-efficient DNN accelerator, _data
reuse_ is a key aspect. This is because (usually) these accelerators are
connected to an external SDRAM, and DRAMs are slow and costly to access in
terms of energy in comparison to on-chip memory (SRAM). It is therefore more
energy-efficient and faster to identify data that is reused many times, copy it
from off-chip DRAM to on-chip SRAM, and then read it from SRAM many times to
amortize the energy and latency cost of fetching it from DRAM.

What can be reused in our accelerator? If you have a look at the
`apply_layer_dot()` function, you will see that `ifmap` and `n_in` are the same
for all of the loop iterations. This means that we can reuse the input
activations across multiple invocations of our dot product accelerator!

**Step 6A:**
As a first step, copy your `wordcopy.sv` from Task 5 and `dot.sv` file from
Task 6 into Task 7.  Next, use Platform Designer to add the `bank0` and `bank1`
memories according to the [memory map](#memory-map).  Make sure the size and
starting addresses are correct.  Also, make sure the three data master ports
(Nios II processor data master, your `dot` accelerator master from Task 6, and
your `wordcopy` accelerator master from Task 5) can access all three memories
(`bank0`, `bank1`, and the SDRAM).  The `copymem()` C function will be used
used to copy the initial input data (an image) into `bank0`. With this change,
a complete inference calculation should be faster than Step 5.

**Step 6B:**
To make your accelerator even faster, copy your `dot` accelerator design into
`dotopt.sv`. In this new module, add a second Avalon master port to your
accelerator.  Connect the first (original) master port to SDRAM only. Connect
the second (new) master port to only `bank0` and `bank1`.  In the end, the
SDRAM will have three masters (Nios II, `wordcopy`, and the first `dotopt`
port) and each SRAM bank will have three masters (Nios II, `wordcopy`, and
second `dotopt` port).  (While other organizations are possible, they will use
more logic and may compromise clock speed. If you try it, let us know how much
extra logic and clock speed is given up.) This organization ensures that
concurrent reads can be made to both SDRAM and SRAM.

With multiple master ports, your `dotopt` accelerator is potentially able to
read the input (ifmap) values and the weight values concurrently. Of course,
your control FSM also needs to be designed to perform both operations in
parallel.  Since reading a weight value from SDRAM will always be slower, you
can use this fact to simplify your control FSM (note: normally this is a very
bad idea, but we will allow it in this lab).

For this task, you will add the `wordcopy`, `dot` and `dotopt` modules to your
Nios II computer system. Both `dot` and `dotopt` should use the same base
address, but only one of them should be enabled in Platform Designer.  If you
do not complete the `dotopt` module, leave the skeleton file empty as it was
provided (do not submit broken code) and do not enable it in Platform Designer.

**Note:** although you are not submitting a SYN testbench for this task, we will still synthesize your RTL and run it through our own testbench.



### Optional Task 8: The complete neural network accelerator

This task is optional.

In this task, you will design a complete neural network
accelerator. This accelerator computes the inner product _w_·_a_, adds a
bias _b_, and optionally applies the ReLU activation function to the result.
Like the accelerator from Task 7, this accelerator will have a servant and two
master Avalon interfaces.

To set up the computation in `apply_layer_act`, the CPU will write addresses of the bias vector, weight matrix, input and output activations, and the input activation vector length to the following word offsets in your component's address range:

| word offset |                       meaning                      |
| ---- | -------------------------------------------------- |
|   0  | when written, starts accelerator; may also be read |
|   1  | bias vector byte address                           |
|   2  | weight matrix byte address                         |
|   3  | input activations vector byte address              |
|   4  | output activations vector byte address             |
|   5  | input activations vector length                    |
|   6  | _reserved_                                         |
|   7  | activation function: 1 if ReLU, 0 if identity      |

It will also write 1 to word offset 7 if the ReLU activation function is to be used after the dot product has been computed, or 0 if no activation function is to be applied.

As with the previous accelerators, you must use _waitrequest_ appropriately to stall subsequent memory accesses to your accelerator's address range until the dot product computation (and possibly the activation) is finished.

Your component must handle multiple requests; otherwise you won't be able to use it repeatedly to compute the full matrix-vector product. If offsets 1–7 are not changed between two writes to offset 0, they keep their previous values; for example, the user should be able to set the input activations address and the input activations vector length once and make several request to your component.

As before, all weights, biases, and activations here are in **signed Q16.16 fixed point**. Make sure you account for this appropriately when multiplying numbers.

You will find the module skeleton in `dotoptact.sv`, and your RTL testsuite
will go in `tb_rtl_dotoptact.sv`.  To start, you should copy the contents of
`dotopt` from Task 7 into this module.  Then, you should modify the FSM to
fetch the bias value, add it to the sum, optionally implement the activation
function, and then write the final result to the destination memory using the
second master port (so it writes the result to on-chip memory).

Note that you will have to mock up any modules required to thoroughly test your
design, including the SDRAM controller interface.
<!-- The `run_nn.c` file we provided in Task 5 already contains a function that
uses your accelerator to compute a matrix-vector product.-->

**Note:** although you are not submitting a SYN testbench for this task, we will still synthesize your RTL and run it through our own testbench.

To see a much more sophisticated version of this kind of accelerator, you can read the research paper
[DianNao: A Small-Footprint High-Throughput Accelerator for Ubiquitous Machine-Learning](research/diannao-asplos2014.pdf)
from ASPLOS 2014.

In CNNs, you can also reuse weights; for a good example of an accelerator that takes advantage of that, you can read
[Eyeriss: A Spatial Architecture for Energy-Efficient Dataflow for Convolutional Neural Networks](research/2016.06.isca.eyeriss_architecture.pdf)
from ISCA 2016.

## Additional specifications

### Avalon protocol variant

Avalon components can be configured with different protocol variants. For this lab, it is **critically** important that you implement the correct timing:

- In the _Timing_ tab:
  - everything should be greyed out (because `waitrequest` controls the timing), and
  - everything else should be 0.
- In the _Pipelined Transfers_ tab:
  - everything should be 0, and
  - both burst settings should be unchecked.

This should result in a read waveform like this:

<p align="center"><img src="figures/avalon-waitrequest.svg" title="waveforms" width="60%" height="60%"></p>

When you create the component, you will see _Read Waveforms_ and _Write Waveforms_. Make sure these match the protocol variant above.

Resets for the modules you will write are **asynchronous** and **active-low**; be sure to select the appropriate reset type when creating your Avalon components.
(Note: it is likely that **synchronous** resets will work here, but it is untested. Please report back to us if you test this.
At some point we should explain the whole controversy over synchronous versus asynchronous resets -- it's like `vi` versus `emacs`.)


### Memory map

| Component                 |    Base    |    End     |
| ------------------------- | ---------- | ---------- |
| Nios II debug mem servant | 0x00000800 | 0x00000fff |
| JTAG UART                 | 0x00001000 | 0x00001007 |
| PIO (7-segment display)   | 0x00001010 | 0x0000101f |
| Word-copy accelerator     | 0x00001040 | 0x0000107f |
| DOT/DOTOPT accelerators   | 0x00001100 | 0x0000113f |
| DNN accelerator           | 0x00001200 | 0x0000123f |
| VGA adapter               | 0x00004000 | 0x0000401f |
| SRAM bank0                | 0x00006000 | 0x00006fff |
| SRAM bank1                | 0x00007000 | 0x00007fff |
| SRAM instruction memory   | 0x00008000 | 0x0000ffff |
| SDRAM controller          | 0x08000000 | 0x0bffffff |


### Test inputs

The files `test_00` through `test_99` correspond to the following images:

![Test input images](figures/test_images.png)


### Common problems

#### IP component name does not match your Verilog

When adding Quartus IP components, you sometimes run into an annoying problem where Platform Designer can't figure out the top-level module name, and it leaves this as `new_component` (or some variation thereof) when instantiating your module. You would then get errors at synthesis time because `new_component` is unknown.

You can (occasionally) fix this by creating a new IP component, and using the new one. But you can also fix it more easily by directly editing the component definition that is generated when you add the component. To do this, you would find a TCL file named after your component with the suffix `_hw`, such as `counter_hw.tcl`. If you open this file (in any text editor), you will find a line that reads something like

    add_fileset_property QUARTUS_SYNTH TOP_LEVEL new_component

Change `new_component` to your module name (e.g., `counter`), regenerate the Nios II system, and you're good to go.

#### Undefined interrupt or exception servant

You have not defined the memory where the Nios II should go on reset and when architectural exceptions occur. Go back to the Platform Designer tutorial and find out how to do that.

#### Other Platform Designer errors

You have probably forgotten some connections among the components, e.g., clock or reset.

#### The Monitor can download the .sof, but not your C / assembly program

You have probably failed to connect clocks and resets correctly in Platform Designer. In particular, make sure the PLL reset is **not** connected to the debug reset interface of the CPU, only to the external reset — otherwise every time you try to load a program in the CPU, the whole system loses its clock source.

#### In Monitor: ERROR: Value element ... is not a hexadecimal value

You forgot to specify that the `.bin` file should be treated as binary.

#### In Monitor: make: *** No rule to make target 'compile'. Stop.

You need to edit the makefile generated by the Monitor and add the folllowing lines:
```
compile: COMPILE
clean: CLEAN
```
(this is a bug in the Monitor tool version 18.1).

#### In Monitor: your software on the Nios II hangs.

You need to change the `LD_FLAGS` described in Task 1.

(this is a bug in the Monitor tool version 18.1).




## Deliverables and evaluation

We will use a simplified marking method this term. I will leave the previous marking process below for you, so you know what you're missing.
**Do** keep the file names and structure as per the instructions in [Autograder Marking Process](#autograder-marking-process).

Your grade will have two components:

1. Demo and interview during your lab session: 10 marks (breakdown by task below)
1. Code quality check: grade multiplier 0.0 to 1.5


### Marks Breakdown

#### Task 4 [2 marks]

- `vga_avalon.sv`, `tb_rtl_vga_avalon.sv`, `task4.sv`, `vga_plot.c`, `main.c` and all related files needed to synthesize in Quartus
- Any related files needed to implement and test the above `vga_avalon` module
- Any Verilog/C/assembler and similar/related files (eg, executables, data) needed to test your processor system
- Any memory images you read in testbenches in this folder.


**Note:** a major part of this task is just getting the entire Nios II computer system built. Building the Avalon `vga_avalon` module is the easy part!

**Note:** the autograder will be marking the Verilog code that you submit for your `vga_avalon` module. It will also synthesize your processor system. It will not run the software.

**Note:** we will ask you to demonstrate an operational processor system during the Demo, either using the FPGA Monitor Program or ModelSim.


#### Task 5 [2 marks]

- `wordcopy.sv`, `tb_rtl_wordcopy.sv`, `task5.sv`, and all related files needed to synthesize in Quartus
- Any related files needed to implement and test the above `wordcopy` module
- Any Verilog/C/assembler and similar/related files (eg, executables, data) needed to test your processor system including the `wordcopy` module
- Any memory images you read in testbenches in this folder.

**Note:** the autograder will be marking the Verilog code that you submit for your `wordcopy` module. It will also synthesize your processor system. It will not run the software.

**Note:** we will ask you to demonstrate an operational processor system during the Demo, either using the FPGA Monitor Program or ModelSim.


#### Task 6 [3 marks]

- `dot.sv`, `tb_rtl_dot.sv`, `task6.sv`, and all related files needed to synthesize in Quartus
- Any related files needed to implement and test the above `dot` module
- Any Verilog/C/assembler and similar/related files (eg, executables, data) needed to test your processor system
- Any memory images you read in testbenches in this folder.

**Note:** the autograder will be marking the Verilog code that you submit for your `dot` module. It will also synthesize your processor system. It will not run the software.

**Note:** we will ask you to demonstrate an operational processor system during the Demo, either using the FPGA Monitor Program or ModelSim.


#### Task 7 [3 marks]

- `wordcopy.sv`, `dot.sv`, `dotopt.sv`, `tb_rtl_dotopt.sv`, `task7.sv`, and all related files needed to synthesize in Quartus
- Any related files needed to implement and test the above `wordcopy`, `dot`, `dotopt` modules
- Any Verilog/C/assembler and similar/related files (eg, executables, data) needed to test your processor system
- Any memory images you read in testbenches in this folder.
- All other files required to implement and test your task, _including_ any on-chip memories you generated and instantiated in your accelerator component

**Note:** the autograder will mark the Verilog code that you submit for the `dotopt` task module only. However, it will also synthesize your processor system which includes the two prior modules as well as `dotopt`. The AG will not run software.

**Note:** we will ask you to demonstrate an operational processor system during the Demo, either using the FPGA Monitor Program or ModelSim.


#### Optional Task 8 [0 marks]

- `wordcopy.sv`, `dotoptact.sv`, `tb_rtl_dotoptact.sv`, `task8.sv`, and all related files needed to synthesize in Quartus
- Any related files needed to implement and test the above `dotoptact` module
- Any Verilog/C/assembler and similar/related files (eg, executables, data) needed to test your processor system
- Any memory images you read in testbenches in this folder.

**Note:** the autograder will mark the Verilog code that you submit for your `dotoptact` module. It will also synthesize your processor system. It will not run the software.

**Note:** we will ask you to demonstrate an operational processor system during the Demo, either using the FPGA Monitor Program or ModelSim.



## Autograder Marking Process

The autograder will not be used in 2022W1. This section is kept intact for legacy purposes.

We will be marking your code via an automatic testing infrastructure. Your
autograder marks will depend on the fraction of the testcases your code passed
(i.e., which features work as specified), and how many cases your testbenches
cover adjusted to the fraction of the testcases that pass.

It is essential that you understand how this works so that you submit the
correct files — if our testsuite is unable to compile and test your code, you
will not receive marks.

The testsuite evaluates each task separately. For each design task folder
(e.g., `task4`), it collects all Verilog files (`*.sv`) that do not begin with
`tb_` and compiles them **all together**. Separately, each required `tb_*.sv`
file is compiled with the relevant `*.sv` design files. This means that

1. You must not **rename any files** we have provided.
2. You must not **add** any files that contain unused Verilog code; this may cause compilation to fail.
3. Your testbench files must begin with `tb_` and **correspond to design file names** (e.g., `tb_rtl_foo.sv` for design `foo.sv`).
4. You must not have **multiple copies of the same module** in separate committed source files in the same task folder. This will cause the compiler to fail because of duplicate module definitions.
5. Your modules must not **rely on files from another folder**. In particular, this means that any memory images you read in your testbenches must be present in the same folder. The autograder will only look in one folder.

The autograder will instantiate and test each module exactly the way it is defined in the provided skeleton files. This means that

1. You must not **alter the module declarations, port lists, etc.**, in the provided skeleton files.
2. You must not **rename any modules, ports, or signals** in the provided skeleton files.
3. You must not **alter the width or polarity of any signal** in the skeleton files (e.g., everything depending on the clock is posedge-triggered, and `rst_n` must remain active-low).
4. Your sequential elements must be triggered **only on the positive edge of the clock** (and the negative edge of reset if you have an asynchronous active-low reset). No non-clock (or possibly reset) signal edges, no negative-edge clock signals, or other shenanigans.
5. You must not add logic to the clock and reset signals (e.g., invert them). When building digital hardware, it is extremely important that the clock and reset arrive at exactly the same time to all your FFs; otherwise your circuit will at best be slow and at worst not working.

If your code does not compile, synthesize, and simulate under these conditions
(e.g., because of syntax errors, misconnected ports, or missing files), you
will receive **0 marks**.


### Autograder Marks

The evaluation of your submission consists of three parts:
- *25%*: automatic testing of your autograder RTL code (`*.sv`)
- *25%*: automatic testing of the netlist we synthesize from your autograder RTL
- *25%*: automatic testing of your autograder RTL testbench coverage (`tb_rtl_*.sv`)
- *25%*: automatic synthesizing and manual review/testing of your processor system

**Note:** the autograder will synthesize your processor systems in Quartus. To
do this, GitHub must have all of the files generated by Platform Designer that are
actually used by Quartus. Please don't commit/push absolutely all files in your
project, just commit/push the ones required to synthesize. Including too many
files, especially binary files, will slow down git dramatically (and the AG has
to do it for all 100 students). To do this, start by commiting only the files
you are absolutely certain are needed. After your local commit, but before
pushing to GitHub, create a fresh local clone of your local working repository
and run Quartus from within that new clone. Quartus will probably fail with an
error because you missed a file. Go back to the local working repository,
add/commit the missing file, then go to the local clone repository and pull the
changes from the working repository, and re-run Quartus. Repeat until Quartus
synthesizes without any errors. Once it is complete, you can go to the local
working repository and push that to GitHub.

