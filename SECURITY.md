# Security policy

## Reporting

Please report authentication, authorization, or data-exposure issues privately to the repository owner through the contact method listed on the GitHub profile. Do not publish credentials or user data in an issue.

## Firebase expectations

- Treat Firebase API keys as identifiers and enforce access with Authentication, Firestore Rules, Storage Rules, and App Check.
- Use separate Firebase projects for development and production.
- Never commit service-account credentials, private keys, exported user data, or database backups.
- Review rules in the Firebase Emulator Suite before deployment.
- Restrict enabled sign-in providers and authorized domains to those the app needs.

The example Firestore rules in this repository are deny-by-default and must be expanded deliberately as backend features are introduced.
