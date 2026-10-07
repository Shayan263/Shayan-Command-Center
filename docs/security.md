# Security

## Purpose

This document defines the security rules for Shayan Command Center and the development practices the project should follow.

## Rules

- Never commit passwords, API keys, tokens, private certificates, or other secrets.
- Never place secrets directly in Swift source, configuration committed to Git, logs, screenshots, or test fixtures.
- Treat all user-provided text as untrusted input. Validate, constrain, and safely encode it before using it in commands, URLs, file paths, queries, or external requests.
- Prefer Apple Keychain for sensitive local credentials and protected data. Use the strongest practical accessibility setting that matches the feature's requirements.
- Keep sensitive data out of analytics, debug logs, crash messages, and telemetry unless explicitly required and protected.
- Use HTTPS/TLS for network communication and validate server responses before trusting data.
- Apply least privilege to app capabilities, integrations, and permissions.
- Do not add external AI/API integrations or secret storage unless the feature is explicitly approved.
- Security-sensitive changes must be reviewed and tested before production merge.

## Current App Direction

AI/API integrations are currently paused. Do not re-enable Gemini, OpenAI, Gmail, or similar integrations merely to satisfy a feature request without an explicit project decision and corresponding secret-management design.

## Incident Rule

If a credential is accidentally exposed, revoke or rotate it immediately, remove it from active source, and investigate repository history before considering the issue resolved.
