# Demo Credentials Warning

Demo accounts are for staging only. Demo passwords must not be used in
production.

Staging demo password:

```text
Password123!
```

The SQL seeds contain only a bcrypt hash. If backend authentication later uses
a different password-hash mechanism or cost, regenerate the demo hashes before
using the accounts.

Do not use real personal data or real passenger ID numbers in staging seed
data. Identity document rows are intentionally not seeded.
