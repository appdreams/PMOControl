# SPEC-001 — Authentication — Events

**Status:** Draft — lifecycle event contract

Authentication uses provider-managed events for session telemetry. Domain events are emitted for `MembershipGranted` and `MembershipRevoked` by the membership owner (Spec 002/003), not as copies of credentials. Login/recovery success/failure telemetry is minimized and rate-limited; never emit password, token, recovery link or raw credential. Security events are auditable per retention policy.
