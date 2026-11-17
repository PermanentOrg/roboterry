#!/usr/bin/env node
// Launches the dbhub MCP server used by the "db" entry in .mcp.json.
//
// Plain Node with no bash, npx, or extra dependencies, so it behaves the same
// on Windows, macOS, and Linux. It reads DATABASE_PASSWORD and DATABASE_HOST
// from the repo's .env file (tolerating CRLF line endings and a UTF-8 BOM, as
// written by Windows editors), builds the read-only DSN, and runs the locally
// installed dbhub with stdio passed straight through.
//
// stdout is the MCP protocol channel: all diagnostics must go to stderr.

import { spawn } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = join(dirname(fileURLToPath(import.meta.url)), "..");
const envPath = join(repoRoot, ".env");
const dbhubEntry = join(
	repoRoot,
	"node_modules",
	"@bytebase",
	"dbhub",
	"dist",
	"index.js",
);

function fail(message) {
	console.error(`[start-db-server] ${message}`);
	process.exit(1);
}

function readEnvFile(path) {
	if (!existsSync(path)) {
		fail(
			`Missing ${path}. Copy .env.template to .env and fill in the read-only database credentials.`,
		);
	}
	const env = {};
	const text = readFileSync(path, "utf8").replace(/^﻿/, "");
	for (const rawLine of text.split(/\r?\n/)) {
		const line = rawLine.trim();
		if (line === "" || line.startsWith("#")) continue;
		const match = /^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/.exec(
			line,
		);
		if (!match) continue;
		let value = match[2];
		const quote = value[0];
		if (
			value.length >= 2 &&
			(quote === '"' || quote === "'") &&
			value.at(-1) === quote
		) {
			value = value.slice(1, -1);
		}
		env[match[1]] = value;
	}
	return env;
}

function requireValue(env, name) {
	const value = env[name];
	if (!value || value.startsWith("<")) {
		fail(`${name} is not set in ${envPath}. See .env.template.`);
	}
	return value;
}

const env = readEnvFile(envPath);
const password = requireValue(env, "DATABASE_PASSWORD");
const host = requireValue(env, "DATABASE_HOST");

if (!existsSync(dbhubEntry)) {
	fail(
		`dbhub is not installed (${dbhubEntry} not found). Run "npm install" in ${repoRoot}.`,
	);
}

const dsn = `postgres://prodreadonly:${encodeURIComponent(password)}@${host}:5432/permanent?sslmode=require`;

const child = spawn(
	process.execPath,
	[dbhubEntry, "--dsn", dsn, ...process.argv.slice(2)],
	{ cwd: repoRoot, stdio: "inherit" },
);

for (const signal of ["SIGINT", "SIGTERM"]) {
	process.on(signal, () => child.kill(signal));
}

child.on("error", (error) => fail(`Could not start dbhub: ${error.message}`));
child.on("exit", (code, signal) => {
	process.exit(code ?? (signal ? 1 : 0));
});
