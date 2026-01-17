# Architectural Decisions

> This log captures important technical decisions for context across all agents.
> Every non-trivial choice should be documented here.

## Decisions

### DEC-001: User ID Format
**Date:** 2025-01-16  
**Task:** 001  
**Status:** Decided

**Context:**
Need to choose between auto-incrementing integers and UUIDs for user primary keys.

**Decision:**
Use UUIDv4 for user IDs.

**Rationale:**
- Better for distributed systems if we scale horizontally
- No information leakage (can't guess user count from ID)
- Safe to expose in URLs and APIs
- Slight storage overhead acceptable for benefits

**Alternatives Considered:**
- Auto-increment integers: Simpler, smaller storage, but leaks information and problematic for distributed DB
- UUIDv7: Time-ordered which is nice for indexing, but less library support currently

**Consequences:**
- All foreign keys referencing users will be UUID type
- API responses will include UUID strings
- Need to ensure UUID generation is available in application code

---

### DEC-002: Password Hashing Algorithm
**Date:** 2025-01-16  
**Task:** 001  
**Status:** Decided

**Context:**
Need to select a password hashing algorithm that balances security and performance.

**Decision:**
Use bcrypt with cost factor 12.

**Rationale:**
- Industry standard with proven security track record
- Cost factor 12 provides good security (~250ms hash time) without impacting UX
- Excellent library support in Node.js (bcryptjs)
- Built-in salt handling

**Alternatives Considered:**
- Argon2: Newer and potentially more secure, but less mature library support in Node.js
- PBKDF2: Older standard, less resistant to GPU attacks
- scrypt: Good option but bcrypt more widely understood by team

**Consequences:**
- Login/registration will have ~250ms hashing overhead
- Password verification is CPU-bound (consider for scaling)
- Cost factor may need adjustment as hardware improves

---

### DEC-003: JWT Token Structure
**Date:** 2025-01-16  
**Task:** 003  
**Status:** Decided

**Context:**
Need to define what claims to include in JWT tokens and expiration policy.

**Decision:**
- Access tokens contain: sub (user_id), email, iat, exp
- Access token expiry: 1 hour
- Refresh tokens: Separate opaque tokens stored in database
- Refresh token expiry: 7 days

**Rationale:**
- Minimal payload reduces token size
- Short access token expiry limits exposure if compromised
- Database-stored refresh tokens allow revocation
- 7-day refresh allows reasonable "remember me" functionality

**Alternatives Considered:**
- Longer access tokens (24h): Less secure, harder to revoke
- JWT refresh tokens: Can't be revoked without blocklist
- Include roles/permissions in token: Stale data problem, increases size

**Consequences:**
- Frontend must handle token refresh flow
- Need refresh_tokens table in database
- Logout must invalidate refresh token in DB
