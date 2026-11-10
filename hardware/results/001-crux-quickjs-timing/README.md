# 001 Crux on QuickJS timing: results

Run by Andy Snavley on 2026-11-09 over a shell on the SSP. Built from `spikes/crux-quickjs/build.sh`.
SSP kernel `5.13.13-00056-g5031957dda5b` (2022-07-11), armv7l.

Two runs. `run-20261109-140712` had the SSP software (synthor) running. `run-20261109-140932` had it stopped.

## Verdict

Pass, with little margin on edits.

| Rule | Result |
|---|---|
| Output identical to Node | Yes, both runs (`cmp` exit 0, rechecked against `expected_output.tsv`) |
| Reseed under 2 ms | Yes. Worst 1.25 ms |
| Edit under 500 ms | Yes. Worst 473 ms (balinese-gamelan, synthor running) |

## Numbers

| Program | Edit, synthor stopped | Edit, synthor running | Reseed, stopped |
|---|---|---|---|
| balinese-gamelan | 465 ms | 473 ms | 0.96 ms |
| canon-with-transformations | 205 ms | 210 ms | 0.53 ms |
| displace-anticipation | 110 ms | 111 ms | 0.27 ms |
| displace-fractional | 131 ms | 150 ms | 0.32 ms |
| displace | 114 ms | 141 ms | 0.27 ms |
| fugal-exposition | 274 ms | 343 ms | 1.04 ms |
| mot-timescale | 157 ms | 195 ms | 0.69 ms |
| polyrhythm | 169 ms | 213 ms | 0.40 ms |
| voice-offset | 177 ms | 225 ms | 0.53 ms |

Startup 97 ms. JS heap 1.2 MB.

## Observations

- The SSP is about 7 times slower than the x86 reference for this work (edit 6.6 to 7.2x, reseed 6.5 to 8.7x, startup 7.8x). The earlier guess was 3 to 5x.
- With synthor running, most edits were 14 to 27% slower. Three were within 2%. The cause is not known. CPU contention is the likely one.
- balinese-gamelan has the longest source (835 bytes, mostly comments) and is the slowest edit.
- Reseed is fast enough to run on every beat.
- An edit of 100 to 500 ms is fine when it lands at the next bar. It is too slow to re-parse on every encoder click.
- There is shell access to the SSP. That answers one open question in `docs/workflow.md`.

## Not measured

- Whether a compile on another thread disturbs audio. This needs a test inside a real plugin.
