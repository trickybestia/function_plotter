# function_plotter

Display graph of user defined-function using Nexys A7-100T FPGA development board.

## Vivado project initialization

1. Launch Vivado (developed using v2024.1 but other versions may work too).
2. Using `Tools -> Run Tcl Script...` run [`function_plotter.tcl`](function_plotter.tcl).

### Committing changes

1. Install https://github.com/barbedo/vivado-git.
2. Run `wproj` command in Vivado Tcl Console. This will regenerate [`function_plotter.tcl`](function_plotter.tcl).
3. Commit.
