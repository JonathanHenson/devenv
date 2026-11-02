---
name: cdk-workflow
description: Work on AWS CDK apps safely — synth, diff, and deploy with review. Use for CDK stacks, constructs, or deploying infrastructure.
---

1. Check credentials: `aws sts get-caller-identity`. If expired, ask the user to run
   `aws sso login --sso-session personal`.
2. Find the app type from `cdk.json` (TypeScript, Python, Rust via a container, etc.)
   and install deps (`npm ci` / `uv sync`).
3. `cdk synth` to validate; fix errors before going further.
4. `cdk diff <stack>`; summarize the changes for the user, calling out IAM changes,
   resource replacements and deletions.
5. Only after the user approves: `cdk deploy <stack>`. Never run `cdk destroy` without
   explicit confirmation.
6. Use the aws-iac MCP server for construct or CloudFormation questions.
