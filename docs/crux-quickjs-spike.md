# Crux on QuickJS, spike results

Date 2026-11-07. Code in `spikes/crux-quickjs/`.
SSP timings measured 2026-11-09. See `hardware/results/001-crux-quickjs-timing/`.

## Setup

- Crux source from `animist-os/crux` (`src/`), bundled with ohm-js 17.5 by esbuild (213 KB).
- QuickJS release 2026-06-04. The bundle is precompiled to QuickJS bytecode with `qjsc`.
- A small C host uses the bare engine API, as a plugin would.
- Built for x86/arm64 native and for armv7 hard-float static (`cortex-a17`).

## Results on x86 (Xeon 2.1 GHz)

| Operation | Time |
|---|---|
| Startup (engine, bytecode, grammar) | 12 ms |
| Edit (parse and interpret) | 16 to 67 ms |
| Reseed (interpret a cached program) | 0.04 to 0.15 ms |
| JS heap | 1.8 MB |

All nine Crux examples give byte-identical output in Node, QuickJS on x86, and QuickJS on armv7 under qemu.

## Results on SSP (Rockchip armv7l, fw 2022-07-11)

Checklist 001. Pass: `cmp` clean, every reseed under 2 ms, every edit under 500 ms.

| Operation | Synthor running, patch loaded | Synthor stopped |
|---|---|---|
| Startup | 98.6 ms | 96.8 ms |
| Edit | 111 to 473 ms | 110 to 465 ms |
| Reseed | 0.26 to 1.25 ms | 0.27 to 1.04 ms |
| JS heap | 1.2 MB | 1.2 MB |

Worst edit was `balinese-gamelan.crux` (~470 ms). Worst reseed was `fugal-exposition.crux` (~1.2 ms). Live edit is viable; heavy edits are near the lag line. Reseed is comfortably live.

The SSP is about 7 times slower than the x86 reference (edit 6.6 to 7.2x, reseed 6.5 to 8.7x). With synthor running, most edits were 14 to 27% slower. Edits of 100 to 500 ms are fine when applied at the next bar. They are too slow to re-parse on every encoder click, which points to the faster encoder edits listed below.

Not measured yet: whether a compile on another thread disturbs audio. That needs a test inside a real plugin.

## Findings

1. Ohm parsing is almost all the cost. Interpreting takes about 0.1 ms.
2. Building the Ohm grammar took 650 ms at startup. A precompiled grammar recipe (`g.toRecipe()`, then `ohm.makeRecipe()`) takes 6 ms.
3. Crux caches each Mot's random generator. So a cached program gave wrong results when reseeded. A four-line patch resets the generator once per interpret pass. Cached reseeds now match fresh compiles.
4. Compiles run off the audio thread. The old program keeps playing. The new event list is swapped in at a bar line.

## Making encoder edits faster

- Ohm can re-parse only the changed part of the text (`Matcher.replaceInputRange`).
- An encoder edit that changes one number could patch the cached program directly.
