# PRTS Ly Theme

A PRTS / Rhodes Island themed login screen for [Ly](https://github.com/fairyglade/ly) 1.5+.
It uses Ly's Lua animation API, so no patched binary or desktop environment is required.

## Features

- Rhodes Island-inspired cyan, slate and amber interface palette
- Animated scanning telemetry line and compact terminal HUD
- PRTS authorization copy, branded login box, and safe 24-bit colors
- A sandbox preview command that never writes to `/etc/ly`

## Preview

```sh
./tools/debug_sandbox.sh --check
./tools/debug_sandbox.sh
```

The preview needs `ly-dm`; the login screen is deliberately non-functional in a
regular terminal, but layout and animation can be inspected safely. Press Ctrl+C
to leave it.

For a repeatable TTY capture at the intended 100×30 size (without changing
`/etc/ly`), first assemble the sandbox, then record it with `script`:

```sh
SANDBOX=/tmp/prts-ly-theme-preview ./tools/debug_sandbox.sh --check
script -qefc 'stty cols 100 rows 30; ly-dm -c /tmp/prts-ly-theme-preview' \
  /tmp/prts-ly-theme-100x30.typescript
```

Stop the recording with Ctrl+C and replay it with `scriptreplay` or inspect the
result in a terminal that supports true colour. For an on-screen screenshot,
run `./tools/debug_sandbox.sh` from the target TTY and use the system screenshot
tool; do not capture a real login prompt containing credentials. The HUD switches
to a minimal top/bottom treatment below 80×24, leaving the centred Ly form clear;
the 20-column inputs keep Ly's own form inside a 40-column rescue TTY.

## Install

Review the generated backup location, then run:

```sh
sudo ./tools/install.sh
```

To install into another Ly configuration directory, pass it as the first argument.
The installer backs up an existing configuration and validates the new `config.lua`
before reporting success.

## Layout notes

The animation keeps the centre open for Ly's login dialog. It adapts to terminal
size, though 100×30 or larger gives the intended composition.
