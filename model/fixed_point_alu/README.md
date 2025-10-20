# fixed_point_alu model

To generate file with test inputs and reference outputs run respecting command inside current directory.

To determine if Verilog module behaviour matches reference model run `diff` between Verilog module testbench log file and reference model log file:

```bash
# run from project root
diff model/fixed_point_alu/sub.log vivado_project/function_plotter.sim/fixed_point_sub_tb/behav/xsim/fixed_point_sub_tb.log
# (expect files to be equal)
```

## fixed_point_add model

```bash
python add.py > add.log
```

## fixed_point_sub model

```bash
python sub.py > sub.log
```

## fixed_point_mul model

```bash
python mul.py > mul.log
```

## fixed_point_div model

```bash
python div.py > div.log
```

## fixed_point_pow model

```bash
python pow.py > pow.log
```
