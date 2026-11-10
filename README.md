# sspss

Modules for the Percussa SSP, ported from Golden, Lup and Crux.

Andy Milburn and Andy Snavley work here, each with their own AI coding sessions.
There is one SSP. It is in Andy Snavley's studio.

## Layout

```
docs/              design notes and decisions
hardware/
  checklists/      numbered tasks to run on the SSP
  results/         what came back from each checklist
spikes/            throwaway experiments that answer one question
modules/           real SSP modules (none yet)
```

## Status

- Crux runs inside QuickJS. Output matches Node exactly. See `docs/crux-quickjs-spike.md`.
- Checklist 001 done on SSP: edit under 500 ms, reseed under 2 ms. Results in `hardware/results/001-crux-quickjs-timing/`.
- First planned module: Billiards, ported from Lup's `src/shared/billiards_sim.js`.

## Working here

Read `AGENTS.md` before changing anything. It is the rulebook for people and AI sessions.
The workflow is in `docs/workflow.md`.
