# Crux on QuickJS, spike results

Date 2026-11-07. Code in `spikes/crux-quickjs/`.

## Setup

- Crux source from `disrupterbox/crux/src`, bundled with ohm-js 17.5 by esbuild (213 KB).
- QuickJS release 2026-06-04. The bundle is precompiled to QuickJS bytecode with `qjsc`.
- A small C host uses the bare engine API, as a plugin would.
- Built for x86 and for armv7 hard-float (`-mcpu=cortex-a17 -mfpu=neon-vfpv4`, static).

## Results on x86 (Xeon 2.1 GHz)

| Operation | Time |
|---|---|
| Startup (engine, bytecode, grammar) | 12 ms |
| Edit (parse and interpret) | 16 to 67 ms |
| Reseed (interpret a cached program) | 0.04 to 0.15 ms |
| JS heap | 1.8 MB |

All nine Crux examples give byte-identical output in Node, QuickJS on x86, and QuickJS on armv7 under qemu.

Nothing has run on the SSP yet. A rough guess is that its CPU is 3 to 5 times slower for this work. That puts edits near 50 to 350 ms and reseeds under 1 ms. Checklist 001 replaces the guess with numbers.

## Findings

1. Ohm parsing is almost all the cost. Interpreting takes about 0.1 ms.
2. Building the Ohm grammar took 650 ms at startup. A precompiled grammar recipe (`g.toRecipe()`, then `ohm.makeRecipe()`) takes 6 ms.
3. Crux caches each Mot's random generator. So a cached program gave wrong results when reseeded. A four-line patch resets the generator once per interpret pass. Cached reseeds now match fresh compiles.
4. Compiles run off the audio thread. The old program keeps playing. The new event list is swapped in at a bar line.

## If edits are too slow on the SSP

- Ohm can re-parse only the changed part of the text (`Matcher.replaceInputRange`).
- An encoder edit that changes one number could patch the cached program directly.
