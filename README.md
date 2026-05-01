# PRIMO Docker/Wine Simulation Runner

This repository keeps the original PRIMO installation separate from simulation
cases and provides a Docker image for running PRIMO process folders through
Wine without installing Wine on the host.

## Layout

```text
PRIMO/        Original PRIMO installation files
cases/        Simulation cases mounted from the host
docker/       Docker image and runner script
```

Each runnable case should contain a template process folder:

```text
cases/<case-name>/Proc1.template
```

The template must include at least:

```text
EasyLinac.in
dynaSQ.dat
dynLinac.exe
penEasy_PRIMO_dyna.exe
*.vox
*.mat
```

## Build The Docker Image

From the repository root:

```bash
docker build -f docker/Dockerfile -t primo-wine .
```

The image installs Ubuntu, Wine with 32-bit support, and the PRIMO dynLinac
runtime geometry from:

```text
PRIMO/PenEasyLinac
```

## Run A Simulation

Use:

```bash
docker run --rm \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  -v "$PWD/cases:/cases" \
  primo-wine <case-name> <max-histories>
```

Example:

```bash
docker run --rm \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  -v "$PWD/cases:/cases" \
  primo-wine CL2100_6X 100000
```

The `HOST_UID` and `HOST_GID` variables make the generated files owned by your
host user instead of root.

## What The Runner Does

For each request, the runner:

1. Finds `cases/<case-name>/Proc1.template`.
2. Creates the next available process folder, for example `Proc2`, `Proc3`, etc.
3. Copies the template contents into the new process folder.
4. Removes stale generated output files from the copied template.
5. Updates `EasyLinac.in` with the requested maximum number of histories.
6. Generates two new random seeds and writes them to `EasyLinac.in`.
7. Runs:

```text
dynLinac.exe < dynaSQ.dat > dynLinac.OUT
penEasy_PRIMO_dyna.exe < EasyLinac.in > Easy.Out
```

## Outputs

The output stays in the mounted `cases` folder on the host.

Example:

```text
cases/CL2100_6X/Proc2/
```

Important files:

```text
Easy.Out                 Main PenEasy output log
dynLinac.OUT             dynLinac output log
PENdyn.geo               Generated dynamic geometry
dynSQ.in                 Generated dynamic sequence input
*.IAEAheader             Phase-space header, if enabled
*.IAEAphsp               Phase-space data, if enabled
tallyPhaseSpaceFile.dat  Phase-space tally report, if enabled
```

To confirm the requested histories completed:

```bash
tail -n 40 cases/<case-name>/ProcN/Easy.Out
```

Look for:

```text
report: SIMULATION ENDED
No. of histories simulated:
```

## Available Cases

List case folders:

```bash
find cases -maxdepth 2 -type d -name 'Proc1.template' -printf '%h\n'
```

Current examples include:

```text
cases/CL2100_6X
cases/CL2100_15X
cases/FB_6XFFF
cases/FB_10XFFF
```

## Running Multiple Simulations

Run the same command again with the same case name and a new history count.
The runner will create the next available `ProcN`.

Example:

```bash
docker run --rm \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  -v "$PWD/cases:/cases" \
  primo-wine CL2100_6X 1000000
```

## Troubleshooting

If Docker cannot access the daemon:

```text
permission denied while trying to connect to the Docker daemon socket
```

Run with a user that has Docker access, or use `sudo docker ...`.

If the runner says the template is missing, verify the folder name is exactly:

```text
Proc1.template
```

If `dynLinac` fails, inspect:

```text
cases/<case-name>/ProcN/dynLinac.OUT
```

If PenEasy fails or stops early, inspect:

```text
cases/<case-name>/ProcN/Easy.Out
```

## Notes

The first part of each run can spend significant time initializing geometry and
materials even for a very small number of histories. That is normal.

The Docker image does not use a Windows container. It is an Ubuntu image with
Wine, so it runs on standard Linux Docker hosts.
