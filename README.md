# Staffbot

A conversational interface for querying our production database using Claude Code. Designed for non-technical staff — no SQL or programming knowledge required.

## How It Works

You open Claude Code (locally or on the web), ask a question in plain English, and get an answer pulled from the database. For example:

- "How many users signed up last month?"
- "Show me the top 10 customers by revenue"
- "What's the current status of order #12345?"

Claude translates your question into a database query, runs it, and presents the results in a readable format.

## Setup

There are two ways to use Staffbot: **locally** (Claude Code CLI or desktop app) or **on the web** (claude.ai/code). Both require environment variables to be configured with database and SSH credentials. Ask your team lead or IT for the values.

### Local Setup

1. Install [Claude Code](https://claude.ai/download)
2. Clone this repository:
   ```
   git clone <repository-url>
   cd staffbot
   ```
3. Copy the environment template and fill in your values:
   ```
   cp .env.template .env
   ```
4. Open the `.env` file in a text editor and fill in the values provided by IT. For local use, set `SSH_KEY` to the path of your private key file (e.g. `~/.ssh/staffbot_key`). You can leave `SSH_PRIVATE_KEY_BASE64` blank.
5. Start Claude Code from inside the staffbot directory:
   ```
   claude
   ```

### Web Setup

1. Go to [claude.ai/code](https://claude.ai/code)
2. Connect this repository as your project
3. Open the project's environment variable settings and add each variable from `.env.template`. For the SSH key, use `SSH_PRIVATE_KEY_BASE64` instead of `SSH_KEY`:
   - Ask IT for the base64-encoded key value, or
   - If you have the key file locally, generate it by running `base64 < ~/.ssh/staffbot_key` in a terminal and copying the output
4. Start a new session — the database connection will be established automatically

## Usage Tips

- **Ask in plain English.** You don't need to know SQL or database terminology.
- **Be specific about time ranges.** "Last month" is better than "recently."
- **Ask follow-up questions.** You can refine your question based on previous results.
- **Results stay in the conversation.** Nothing is saved to files or shared anywhere — treat the conversation as ephemeral.

## Security Notes

- The database connection is **read-only**. No data can be modified through this tool.
- Query results may contain **sensitive production data**. Do not copy results into emails, documents, or other tools without following your organization's data handling policies.
- Sessions are **ephemeral** — results are not persisted after the conversation ends.
- The SSH private key is never exposed to the AI model. It is used only by the database connection process.

## Troubleshooting

| Problem                                  | What to do                                                                                         |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------- |
| "MCP server failed to start"             | Your environment variables may be missing or incorrect. Double-check them against `.env.template`. |
| "Connection refused" or timeout          | The SSH tunnel could not reach the bastion host. Verify `SSH_HOST` and `SSH_USER` are correct.     |
| "Permission denied"                      | The SSH key may be invalid or not authorized on the bastion host. Contact IT.                      |
| Claude says it can't access the database | The MCP server may not have started. Try refreshing the session.                                   |
| Unexpected or empty results              | Try rephrasing your question with more specific details (dates, names, etc.).                      |
