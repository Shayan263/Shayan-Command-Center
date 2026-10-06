# Threat Model

## Scope

This threat model covers the iOS app, local storage, optional network integrations, GitHub-hosted source, CI/CD, and future external integrations.

## Key Assets

- User notes and private application data
- Authentication/session material
- API keys and integration credentials
- Analytics and operational data
- Source code and CI/CD configuration
- GitHub repository access

## Threats

| Threat | Example | Primary Protection |
|---|---|---|
| Credential leakage | API key committed to Git | Secret scanning, Keychain, code review |
| Unauthorized access | Stolen session or device access | Authentication, device security, session controls |
| Malicious input | Crafted text reaches a command or URL | Validation, allowlists, safe encoding |
| Data exposure | Sensitive data appears in logs | Redaction, minimal logging |
| Supply-chain risk | Compromised dependency/action | Pin and review dependencies/actions |
| CI compromise | Malicious workflow change or secret misuse | Least-privilege tokens, protected secrets, review |
| Insecure network | Interception or untrusted endpoint | HTTPS/TLS, endpoint validation |
| Excessive permissions | Integration receives unnecessary access | Least privilege and scoped permissions |
| Privacy leakage | Analytics contain personal data | Data minimization and redaction |

## Security Boundaries

Treat the iOS app, external services, GitHub/CI, and any future AI/API provider as separate trust boundaries. Data crossing a boundary must be validated and the receiving component must not be trusted merely because the sender is the app.

## Highest-Priority Risks

1. Secret exposure through source control or logs.
2. Unauthorized access to personal data or integrations.
3. Unsafe handling of untrusted user input.
4. Over-privileged external integrations.
5. CI/CD changes that can access production credentials or alter production artifacts.

## Review Trigger

Update this threat model when authentication, cloud storage, external APIs, AI agents, email access, payment features, or other privileged integrations are introduced.
