# 001 Crux on QuickJS timing

Purpose. Measure how fast Crux compiles and reseeds on the SSP's CPU. This decides whether Crux can be edited live on the module.

Needs. A shell on the SSP. If there is no shell, say so in the results. That answer is useful too.

## Get the binary

Either build it with `spikes/crux-quickjs/build.sh`, or use `crux_host_armv7` from the latest CI artifact or release.

## Run on the SSP

```
chmod +x crux_host_armv7
./crux_host_armv7 > timings.txt
./crux_host_armv7 --dump > output.tsv
cmp output.tsv expected_output.tsv
```

`expected_output.tsv` is in `spikes/crux-quickjs/src/`. `cmp` prints nothing when the files match.

Run it twice. Once with the SSP's normal software running and a patch loaded, and once with it stopped, if that is possible.

## Send back

Put these in `hardware/results/001-crux-quickjs-timing/`.

- `timings.txt` for each run, with a note on what else was running.
- The `cmp` result.
- SSP firmware version.

## Pass rule

- `cmp` reports no difference.
- Reseed is under 2 ms for every example.
- Edit is under 500 ms for every example. Slower than that still works, but edits will feel laggy.

## Reference (x86 Xeon 2.1 GHz)

Startup 12 ms. Edit 16 to 67 ms. Reseed 0.04 to 0.15 ms. JS heap 1.8 MB.
