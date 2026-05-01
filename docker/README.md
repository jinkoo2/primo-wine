# PRIMO Docker/Wine Runner

Build the image from the repository root:

```bash
docker build -f docker/Dockerfile -t primo-wine .
```

The Docker image copies the PRIMO runtime geometry from:

```text
PRIMO/PenEasyLinac
```

Run one simulation by mounting the host `cases` directory:

```bash
docker run --rm \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  -v "$PWD/cases:/cases" \
  primo-wine CL2100_6X 100000
```

The runner expects:

- `/cases/<case-name>/Proc1.template`
- `EasyLinac.in`, `dynaSQ.dat`, `dynLinac.exe`, and `penEasy_PRIMO_dyna.exe` inside the template

For each request it creates the next available `ProcN`, copies `Proc1.template`,
removes old generated output files, sets new random seeds, updates the requested
history count in `EasyLinac.in`, then runs:

```text
dynLinac.exe < dynaSQ.dat > dynLinac.OUT
penEasy_PRIMO_dyna.exe < EasyLinac.in > Easy.Out
```

Example output folder:

```text
cases/CL2100_6X/Proc2
```
