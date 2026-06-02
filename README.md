# Roboterry

A conversational interface for querying our production data using Claude Code. Designed for non-technical staff — no SQL or programming knowledge required.

## How It Works

You open Claude Code, ask a question in plain English, and get an answer pulled from the data. For example:

- "How many users signed up last month?"
- "Show me the top 10 customers by revenue"
- "What's the current status of order #12345?"

Claude translates your question into a database query, runs it, and presents the results in a readable format.

## Setup

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
4. Set `DATABASE_PASSWORD` and `DATABASE_HOST` in your .env. This can be found in Bitwarden under "PostgreSQL prod read-only user"; the password unser "Password" and the host under "Website"
5. Run
   ```
   npm install
   ```
6. Start Claude Code from inside the roboterry directory:
   ```
   claude
   ```

## Usage Tips

- **Ask in plain English.** You don't need to know SQL or database terminology.
- **Be specific about time ranges.** "Last month" is better than "recently."
- **Ask follow-up questions.** You can refine your question based on previous results.
- **Results stay in the conversation.** Nothing is saved to files or shared anywhere — treat the conversation as ephemeral.

## Security Notes

- The data connection is **read-only**. No data can be modified through this tool.
- Results may contain **sensitive production data**. Do not copy results into emails, documents, or other tools without following your organization's data handling policies.
- Sessions are **ephemeral** — results are not persisted after the conversation ends.

## Developer Mode

Roboterry never restricts which tools are available. Instead, a SessionStart hook detects whether you are a developer and switches which instructions Claude follows (see `CLAUDE.md`):

- **Staff mode** (default) — Claude behaves as a read-only, conversational data assistant.
- **Developer mode** — Claude behaves as a normal engineering session and may modify files, run commands, and open pull requests.

To enable developer mode, run:

```
npm run local-developer
```

This creates a `.local-developer` flag file (git-ignored). Restart your session so the SessionStart hook picks it up. To return to staff mode, delete the `.local-developer` file.

## Troubleshooting

| Problem                              | What to do                                                                                |
| ------------------------------------ | ----------------------------------------------------------------------------------------- |
| Claude says it can't access the data | The data connection is configured separately and may not be available on this branch yet. |
| Unexpected or empty results          | Try rephrasing your question with more specific details (dates, names, etc.).             |
