# AGENTS.md

Rules for anyone working in this repo, human or AI. Two people share it, and there is one SSP.

## The hardware constraint

There is one SSP. It is in Andy Snavley's studio. Andy Milburn has no hardware.

- Do as much as possible without the SSP. Test cores on the desktop first.
- Hardware time is batched. Ask for it through a checklist in `hardware/checklists/`.
- Never assume a result on hardware. If it was not measured on the SSP, say so.

## Module code

- `process()` runs on the audio thread. It must not allocate, lock, log or do file I/O.
- Do slow work (Crux compile, sample loading) on another thread. Hand the result to the audio thread without locks.
- Keep each musical core (a sim, a kernel, the Crux event player) free of SSP and UI code. It must build and test on a desktop.
- The SSP plugin interface is `Percussa.h` from https://github.com/percussa/ssp-sdk. Prefer the raw API over JUCE/VST3 unless there is a reason.

## Ports from Lup and Golden

- The JS source in Lup or disrupterbox is the reference. Name the file and commit it came from.
- Every port has a parity test. It drives the JS reference and the port with the same input and compares the output.
- Do not "fix" behaviour during a port. Match first. Change later, in its own commit.

## Hardware checklists

A checklist file is a request for SSP time. Each one has:

1. Number and title, e.g. `002-billiards-first-boot.md`.
2. What to build or download, with exact commands.
3. What to run on the SSP, step by step.
4. What to send back: numbers, files, photos, or a short listening note.
5. A pass/fail rule, where there is one.

Results go in `hardware/results/` under the same number. Include the date, the SSP firmware version, and anything odd.

## Git

- Work on branches. Merge to `main` through a pull request.
- Small commits with plain messages.
- Do not commit build output or binaries. Binaries for the SSP go in CI artifacts or a GitHub release.
- AI sessions that edit a checkout through a mounted folder must not run git writes there. Hand the commands to the person instead.

## Writing

Plain, short sentences. No hype. Say what was measured and what was guessed.
