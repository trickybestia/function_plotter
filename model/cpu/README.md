# cpu reference model

Compile `main.s` into .mem file:

```bash
python -m cpu.cli.compiler examples/main.s compiled_examples/compiled_program.mem
```

Run emulator for 100 ticks:

```bash
python -m cpu.cli.emulator compiled_examples/compiled_program.mem 100
```

Do note that none of the accelerators described in [accelerators.md](../../docs/accelerators.md) are supported.
