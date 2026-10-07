# Security Policy

## Security baseline

Shayan Command Center follows defense-in-depth practices aligned with OWASP ASVS 5.0, OWASP Top 10:2025, and NIST secure-development guidance.

Security controls are enforced in application code and CI where technically applicable. Never commit passwords, API keys, signing certificates, provisioning profiles, private keys, or other credentials.

## Reporting

Do not disclose suspected vulnerabilities publicly. Report them privately to the repository owner with reproduction steps, affected component, and potential impact.

## Production rule

Changes affecting authentication, authorization, secrets, cryptography, privacy, or data access must pass CI/security checks before production release.
