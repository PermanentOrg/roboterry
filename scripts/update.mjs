#!/usr/bin/env node
// Update Roboterry
//
// Pulls the latest main from GitHub and installs dependencies. Only
// fast-forwards, so it never creates merges or touches local changes.
// Staff sessions run this via "npm run update-roboterry", the one shell
// command the sandbox write guard allows in staff mode.
//
// Plain Node with no bash, so it behaves the same on Windows, macOS, and
// Linux.

import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "..");

function fail(message) {
	console.error(message);
	process.exit(1);
}

function run(command, args, { capture = false, shell = false } = {}) {
	const result = spawnSync(command, args, {
		cwd: repoRoot,
		shell,
		env: { ...process.env, GIT_TERMINAL_PROMPT: "0" },
		encoding: "utf8",
		stdio: capture ? ["ignore", "pipe", "inherit"] : "inherit",
	});
	if (result.error) {
		fail(`Could not run ${command}: ${result.error.message}`);
	}
	return { status: result.status, stdout: (result.stdout ?? "").trim() };
}

function npm(args) {
	const npmCli = process.env.npm_execpath;
	return npmCli
		? run(process.execPath, [npmCli, ...args])
		: run("npm", args, { shell: process.platform === "win32" });
}

const branch = run("git", ["symbolic-ref", "--quiet", "--short", "HEAD"], {
	capture: true,
}).stdout;
if (branch !== "main") {
	fail(
		`Roboterry can only update from the main branch (currently on '${branch || "detached HEAD"}').`,
	);
}

const localChanges = run(
	"git",
	["status", "--porcelain", "--untracked-files=no"],
	{ capture: true },
).stdout;
if (localChanges !== "") {
	fail(
		"Roboterry has local changes, so it cannot update automatically. Ask a developer for help.",
	);
}

if (
	run("git", ["pull", "--ff-only", "--quiet", "origin", "main"]).status !== 0
) {
	fail("Roboterry could not download the latest updates.");
}

if (npm(["install", "--no-audit", "--no-fund"]).status !== 0) {
	fail("Roboterry downloaded the updates but could not install dependencies.");
}

console.log("");
console.log(
	"Roboterry is up to date. Start a new Claude Code session so the changes take effect.",
);
