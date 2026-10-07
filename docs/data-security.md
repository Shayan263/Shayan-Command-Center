# Data Security

## Purpose

This document defines how Shayan Command Center should collect, protect, retain, and delete sensitive information.

## Data Classification

### Public
Information intentionally published by the app, such as public portfolio links or non-sensitive application metadata.

### Internal
Application configuration and operational information that should not be unnecessarily exposed.

### Sensitive
User notes, authentication tokens, API credentials, personal contact information, private analytics, and other information that could cause harm or loss if exposed.

## Requirements

- Collect only data required for an explicit feature.
- Do not collect passwords or secrets unless the feature genuinely requires them.
- Store sensitive local data using protected platform storage such as Keychain where appropriate.
- Encrypt sensitive data in transit and use HTTPS for network communication.
- Do not include sensitive data in analytics events or diagnostic logs unless explicitly approved.
- Restrict access to sensitive data using least privilege.
- Define a retention period for every sensitive dataset.
- Delete sensitive data when the feature no longer requires it or when the documented retention period expires.
- When a user requests deletion of supported personal data, remove it from active storage and any associated application cache where practical.
- Avoid copying sensitive data into backups, test fixtures, sample files, or screenshots unless necessary.

## Data Minimization

The app should prefer local processing and storage when practical. New cloud storage or third-party data processing must have a documented purpose, access model, retention policy, and security review.
