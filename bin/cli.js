#!/usr/bin/env node

/**
 * npx orchestra-lite — scaffolds the Orchestra Lite coordination files into the
 * current directory by running the packaged init-orchestra.sh.
 *
 * The generator itself is (deliberately) a bash script — it writes the .orchestra/
 * scaffold with heredocs and is the single source of truth, shellchecked in CI.
 * This wrapper only locates bash and executes it, replacing the previous
 * curl | bash installation instruction with an inspectable, versioned package.
 * Requires bash on PATH (macOS/Linux: built in; Windows: Git Bash).
 */

const { spawnSync } = require("node:child_process");
const path = require("node:path");

const script = path.join(__dirname, "..", "init-orchestra.sh");

const probe = spawnSync("bash", ["--version"], { stdio: "ignore" });
if (probe.error) {
  console.error(
    "orchestra-lite: `bash` was not found on your PATH.\n" +
      "  macOS/Linux: bash ships with the OS.\n" +
      "  Windows: install Git for Windows (provides Git Bash), then re-run from a shell where `bash` resolves."
  );
  process.exit(1);
}

const result = spawnSync("bash", [script], { stdio: "inherit" });
process.exit(result.status ?? 1);
