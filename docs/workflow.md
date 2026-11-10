# Workflow

There is one SSP, in Andy Snavley's studio. Most work does not need it. The workflow keeps hardware time short and specific.

## Desktop first

Each musical core builds and tests on a desktop. For ports, a parity test compares it with the JS original.

Each module will get a desktop harness. The harness calls the plugin interface with fake clocks and inputs. It writes outputs to WAV and the screen to PNG.

The SDK's VST3 route can also load a module in a DAW on a Mac.

## Builds for the SSP

ARM builds cross-compile on Linux or macOS. A plugin `.so` must link against Percussa's buildroot so it matches the SSP's libraries.

The plan is a GitHub Actions job that builds every module for the SSP. Andy Snavley then downloads a finished build. He does not need our toolchain.

## Hardware sessions

1. Someone writes a checklist in `hardware/checklists/`.
2. Andy Snavley, or his AI session, runs it on the SSP.
3. Results go in `hardware/results/` with the same number.
4. Work continues from the results.

## Who does what

- Andy Milburn. Musical design, Crux, and ports from Golden and Lup.
- Andy Snavley. Hardware runs, the deploy loop to the SSP, and how modules feel to play.
- Both. Code, review, and design calls in pull requests.

Andy Snavley already has an SSP workflow. This repo uses his deploy method and his answers on volts, outputs and threads.

## Open questions for the SSP

- Shell access: yes. `ssh root@192.168.1.6` over USB-ethernet (dropbear). Password on stock images is `123456`; key auth preferred.
- How do plugin floats map to volts? This matters for V/oct outputs.
- How many outputs can one module declare?
- May a plugin start its own thread?
- Fastest `.so` deploy so far: `scp -O` to `/media/BOOT/plugins/` then restart synthor (SSP Manager or `serendipity-ssp/scripts/deploy.sh`).
