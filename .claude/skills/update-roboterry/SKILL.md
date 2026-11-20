---
name: update-roboterry
description: Install the latest Roboterry updates from GitHub.
disable-model-invocation: true
---

The user asked to install the latest Roboterry updates.

Run exactly `npm run update-roboterry` with the Bash or PowerShell tool. It is the one shell command staff mode permits, and it updates the Roboterry code and its dependencies outside `sandbox/`; that is expected.

- If it succeeds, tell the user in plain language that the update is installed and that they need to start a new session for it to take effect (in the desktop app, start a new session; in a terminal, type `/exit` and run `claude` again).
- If it reports that Roboterry is already up to date, say so.
- If it fails, explain the problem in plain language and suggest they ask a developer for help. Do not try to fix it another way.
