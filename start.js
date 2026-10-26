// start.js - lets "npm start" run the app on both Mac and Windows.
//
// The app itself is Python. This file only figures out where Python is
// on the current computer, then runs app.py with it.
//
// The first time it runs, it also does the one-time setup:
// it creates the venv folder and installs requirements.txt.

const { spawnSync } = require("child_process");
const fs = require("fs");

const isWindows = process.platform === "win32";

// Windows and Mac put Python in different places inside the venv folder.
const venvPython = isWindows ? "venv\\Scripts\\python.exe" : "venv/bin/python";

// Runs a command and shows its output, like typing it in the terminal.
function run(command, args) {
  const result = spawnSync(command, args, { stdio: "inherit" });
  if (result.error) {
    console.error(`Couldn't run "${command}". Is Python installed?`);
    process.exit(1);
  }
  return result.status;
}

// One-time setup: only happens if the venv folder doesn't exist yet.
if (!fs.existsSync(venvPython)) {
  console.log("First run: setting up Python packages (one time only)...");
  const systemPython = isWindows ? "python" : "python3";
  if (run(systemPython, ["-m", "venv", "venv"]) !== 0) process.exit(1);
  if (run(venvPython, ["-m", "pip", "install", "-r", "requirements.txt"]) !== 0) process.exit(1);
}

console.log("Starting CareChart at http://localhost:3000  (press Ctrl+C to stop)");
run(venvPython, ["app.py"]);
