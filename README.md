# Roboterry

A conversational interface for querying our production data using Claude Code. Designed for non-technical staff — no SQL or programming knowledge required.

## How It Works

You open Claude Code, ask a question in plain English, and get an answer pulled from the data. For example:

- "How many users signed up last month?"
- "Show me the top 10 customers by revenue"
- "What's the current status of order #12345?"

Claude translates your question into a database query, runs it, and presents the results in a readable format.

## Setup

### Linux or Mac

1. Install [Claude Code](https://claude.ai/download)
2. Clone this repository:
   ```
   git clone <repository-url>
   cd roboterry
   ```
3. Run
   ```
   cp .env.template .env
   ```
4. Set `DATABASE_PASSWORD` and `DATABASE_HOST` in your .env. This can be found in Bitwarden under "PostgreSQL prod read-only user"; the password under "Password" and the host under "Website"
5. Run
   ```
   npm install
   ```
6. Start Claude Code from inside the roboterry directory:
   ```
   claude
   ```

### Windows

1. Open the Command Prompt tool
2. Run
   ```powershell
   winget install Git.Git
   ```
   Accept the terms & conditions when prompted
3. Run the following commands
   ```powershell
   cd ~
   mkdir permanent
   cd permanent
   git clone https://github.com/PermanentOrg/roboterry.git
   cd roboterry
   ```
4. Create the .env file with
   ```powershell
   copy .env.template .env
   ```
5. Then open the .env file with
   ```powershell
   edit .env
   ```
6. Set `DATABASE_PASSWORD` and `DATABASE_HOST` in your .env. These can be found in Bitwarden under "PostgreSQL prod read-only user"; the password under "Password" and the host under "Website"
7. Save and close the .env file with CTRL+S, then CTRL+Q
8. Download the [Node Windows Installer](https://nodejs.org/en/download) and run it. Click Next on each page of the install wizard.
9. Back in your Command Prompt, run
   ```powershell
   npm install
   ```
10. Open a Claude Code session in Claude Desktop and ask it to tell you something about the database

## Usage Tips

- **Ask in plain English.** You don't need to know SQL or database terminology.
- **Be specific about time ranges.** "Last month" is better than "recently."
- **Ask follow-up questions.** You can refine your question based on previous results.
- **Results stay in the conversation by default.** Nothing is shared anywhere outside it.
- **Ask for a saved copy when you need one.** If you want a report, spreadsheet, or other file, just ask. Roboterry saves it to the `sandbox/` folder in the project — a private workspace on your computer that is never committed or shared. See `sandbox/README.md` for details.

## Staying Up to Date

When you start Claude Code on the `main` branch, Roboterry checks GitHub for updates. If any are available, you'll see a notice. Type `/update-roboterry` to install them, or just start chatting and Terry will ask whether you want to. Once the update finishes, start a new session so the new tools and instructions load — in the desktop app, start a new session; in a terminal, type `/exit` and run `claude` again.

You can type `/update-roboterry` in Claude at any time, or update from a terminal:

```
npm run update-roboterry
```

The check is skipped in developer mode, on other branches, or when you have local changes.

## Security Notes

- The data connection is **read-only**. No data can be modified through this tool.
- Results may contain **sensitive production data**. Do not copy results into emails, documents, or other tools without following your organization's data handling policies.
- Conversations are **ephemeral** — results are not persisted after the conversation ends unless you ask Roboterry to save them.
- The only place Roboterry writes the files you ask for is the git-ignored `sandbox/` directory. (Installing an update is the one exception: it changes the Roboterry code and its dependencies, and only when you agree to it.) Its contents stay on your machine and can never be committed to git or pushed to GitHub. This is enforced mechanically by a `PreToolUse` hook (`scripts/sandbox-write-guard.sh`), not just by instructions — in staff mode, Claude's own writes outside `sandbox/` and all shell commands other than the updater, `npm run update-roboterry`, are blocked.

## Developer Mode

A SessionStart hook detects whether you are a developer and switches which instructions Claude follows (see `CLAUDE.md`). In staff mode a `PreToolUse` hook also enforces the boundary mechanically; developer mode is unrestricted:

- **Staff mode** (default) — Claude behaves as a read-only, conversational data assistant. Writes are confined to `sandbox/`, and subagents and shell commands (other than `npm run update-roboterry`) are blocked.
- **Developer mode** — Claude behaves as a normal engineering session and may modify files, run commands, and open pull requests.

To enable developer mode, run:

```
npm run local-developer
```

This creates a `.local-developer` flag file (git-ignored). Restart your session so the SessionStart hook picks it up. To return to staff mode, delete the `.local-developer` file.

## Troubleshooting

| Problem                                                                 | What to do                                                                    |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Claude says it can't access the data                                    | Ask an engineer                                                               |
| Unexpected or empty results                                             | Try rephrasing your question with more specific details (dates, names, etc.). |
| `npm install` fails on Windows with an error mentioning ExecutionPolicy | Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`    |
