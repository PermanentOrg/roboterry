#!/usr/bin/env node
// Update Check (SessionStart hook)
//
// In staff mode, checks GitHub for new Roboterry commits on main and,
// if any exist, tells the user and asks Claude to offer installing
// them with "npm run update-roboterry" (the one shell command the sandbox
// write guard permits in staff mode). Stays silent whenever an update could
// not be applied cleanly: developer mode, a branch other than main,
// local changes, a diverged history, or a failed fetch.
//
// Plain Node with no bash, so it behaves the same on Windows, macOS, and
// Linux.

import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "..");

function git(args) {
	const result = spawnSync("git", args, {
		cwd: repoRoot,
		env: { ...process.env, GIT_TERMINAL_PROMPT: "0" },
		encoding: "utf8",
		stdio: ["ignore", "pipe", "ignore"],
	});
	return {
		ok: !result.error && result.status === 0,
		stdout: (result.stdout ?? "").trim(),
	};
}

function newCommitCount() {
	if (existsSync(join(repoRoot, ".local-developer"))) return 0;
	if (git(["symbolic-ref", "--quiet", "--short", "HEAD"]).stdout !== "main")
		return 0;

	const status = git(["status", "--porcelain", "--untracked-files=no"]);
	if (!status.ok || status.stdout !== "") return 0;

	if (!git(["fetch", "--quiet", "origin", "main"]).ok) return 0;
	if (!git(["merge-base", "--is-ancestor", "HEAD", "origin/main"]).ok) return 0;

	return Number(git(["rev-list", "--count", "HEAD..origin/main"]).stdout) || 0;
}

const count = newCommitCount();
if (count > 0) {
	process.stdout.write(
		JSON.stringify({
			systemMessage:
				"There are some updates to the roboterry code available. Type /update-roboterry to install them.",
			hookSpecificOutput: {
				hookEventName: "SessionStart",
				additionalContext: `Roboterry updates are available (${count} new change(s) on GitHub). The user has been shown a notice that they can type /update-roboterry to install them; if their first message is that command, follow it and skip the question below. Otherwise, before doing anything else in your first reply, use the AskUserQuestion tool to ask exactly "There are some updates to the roboterry code available. Wanna install them?" (header "Update") with exactly two options: "Sure, what's the worst that could happen..." and "No.". Then continue with whatever the user asked. Only if they choose the first option, run exactly \`npm run update-roboterry\` with the Bash or PowerShell tool (it is the one command staff mode permits). When it succeeds, tell them the update is installed and that they need to start a new session for the changes to take effect (in the desktop app, start a new session; in a terminal, type /exit and run claude again). If it fails, explain in plain language and suggest they ask a developer for help. If they decline, do not ask again this session.`,
			},
		}),
	);
}
