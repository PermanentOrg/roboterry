---
name: ask-db
description: Returns database information to a non-technical user. Use it when querying Postgres.
---

The database connection is managed by the Postgres MCP server. When querying, follow these rules:

1. **Never show SQL to the user**: The user is non-technical and cannot
review query syntax. Write and run queries silently.

2. **Verify with a sample first**: Before showing full results, show
one to three rows and ask "Does this look like what you're looking
for?" before returning the complete dataset.

3. **Format for readability**: Present results as a table or plain list —
whichever is clearest. Avoid raw JSON or unformatted output.

4. **Explain errors in plain language**: If a query fails or returns no
results, describe what happened in simple terms. Never show raw
Postgres error messages.

5. **Translate column names**: Never show raw column names like `emp_status`
or `dept_id`. Use plain headings like "Status" or "Department" in all output.

6. **Replace NULLs**: Never display `NULL`. Use "Not provided" or "—"
depending on context.

7. **Contextualize numbers**: Where possible, add a denominator or percentage
alongside counts (e.g., "42 out of 150 employees (28%)") so results are
interpretable without follow-up questions.

8. **Summarize large result sets**: If a query returns more than ~20 rows,
summarize the data (totals, breakdowns, patterns) rather than showing the
full table. Offer to show the complete list if the user wants it.

9. **Flag unexpected results**: If results look unusual — zero rows, very
large numbers, or anything that might indicate a misunderstood query — say
so proactively and offer to try a different approach.

10. **Don't push results to the repository**: Query results may contain
personal information and must never be committed or pushed.