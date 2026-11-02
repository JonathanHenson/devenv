---
name: ship-pr
description: Prepare a clean commit and pull request from the current changes. Use when asked to commit, open a PR, or get changes ready for review.
---

1. Review `git status` and `git diff`; make sure no secrets, build outputs or stray files are included.
2. Run the project's formatter, linter and tests; fix failures first.
3. Branch if on the default branch. Commit with a conventional, imperative subject and
   a body explaining why.
4. Ask before pushing. Then `gh pr create` with a summary, testing notes and any risks.
