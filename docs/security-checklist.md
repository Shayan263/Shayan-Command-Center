# Security Checklist

Use this checklist before production releases and after security-sensitive changes.

## Secrets

- [ ] No passwords, API keys, tokens, certificates, or private keys are committed.
- [ ] Secrets are stored in approved protected storage or CI secret management.
- [ ] Debug output does not expose secrets.
- [ ] Test fixtures contain no real credentials.

## Authentication & Authorization

- [ ] Protected resources require authentication.
- [ ] Authorization is enforced at the resource/service boundary.
- [ ] Least privilege is applied.
- [ ] Logout/session invalidation works as intended.
- [ ] Authentication failures fail closed.

## Data Protection

- [ ] Sensitive local data uses appropriate protected storage.
- [ ] Network traffic uses HTTPS/TLS.
- [ ] Sensitive data is absent from logs and analytics unless explicitly required.
- [ ] Retention and deletion behavior is documented.
- [ ] Unnecessary sensitive data is not collected.

## Input & Integrations

- [ ] User input is treated as untrusted.
- [ ] URLs, paths, commands, and external requests are validated.
- [ ] External integrations request only necessary permissions.
- [ ] Third-party responses are validated before use.

## CI/CD & Repository

- [ ] GitHub Actions use the minimum required permissions.
- [ ] Workflow changes are reviewed.
- [ ] Dependencies/actions are reviewed and kept current.
- [ ] Production changes are validated by CI before merge.
- [ ] No unrelated security-sensitive changes are bundled into a release.

## Release Gate

A release should not proceed when a known critical security issue remains unresolved or when a required security control cannot be verified.
