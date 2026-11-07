# Spike: Crux on QuickJS

Question. Can an SSP module run the real Crux interpreter, so Crux can be edited and reseeded on the module?

Answer so far. Yes on desktop, with output identical to Node. Speed on the SSP is not measured yet. See `docs/crux-quickjs-spike.md`.

## Build

```
CRUX_DIR=/path/to/disrupterbox/crux ./build.sh
```

Needs node, npm, git, a C compiler, and `arm-linux-gnueabihf-gcc` for the SSP binary.
Output goes to `build/`. The script ends with a parity check against `src/expected_output.tsv`.

## Files

- `src/crux_host.c` is the test host. It uses the bare QuickJS API, as a plugin would.
- `src/entry_ssp.js` defines `cruxEdit(src, seed)` and `cruxReseed(seed)`.
- `src/crux-reseed.patch` lets a cached Crux program be reseeded. It should go upstream into Crux.
- `src/expected_output.tsv` is Node's output for the nine Crux examples with seed 1234.
