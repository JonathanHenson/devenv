---
name: agentcore-rust-deploy
description: Build a Rust agent for linux/arm64 and deploy it to Amazon Bedrock AgentCore Runtime. Use when creating, building, packaging or deploying Rust agents to AgentCore.
---

1. Verify credentials (`aws sts get-caller-identity`) and that OrbStack/Docker is running
   (`docker info`).
2. Build for AgentCore's architecture (linux/arm64):
   - container image: multi-stage Dockerfile with `--platform=linux/arm64`, or
   - binary: `cargo zigbuild --release --target aarch64-unknown-linux-gnu`.
3. Run tests and clippy before packaging (`cargo nextest run`, `cargo clippy -- -D warnings`).
4. Smoke-test the container locally (`docker run --platform linux/arm64 -p 8080:8080 <image>`),
   hitting the agent's `/invocations` and `/ping` endpoints.
5. Deploy with the project's existing path (CDK stack or the `agentcore` CLI). Show the
   user what will change and get approval before `cdk deploy` / `agentcore launch`.
6. Use the aws-agentcore and aws-docs MCP servers for current AgentCore APIs and limits.
