# Task 001: Design User Database Schema

## Metadata
| Field | Value |
|-------|-------|
| **ID** | 001 |
| **Status** | done |
| **Branch** | task/001 |
| **Assigned** | task/001 |
| **Depends** | none |
| **Blocked-By** | |
| **Estimated** | 45 min |

## Inputs
- None (first task)

## Description
Design and implement the database schema for user authentication. Create the users table with all necessary fields for authentication, password reset, and basic account management. Include proper indexes and constraints.

## Acceptance Criteria
- [x] Users table created with migration
- [x] Fields: id (UUID), email, password_hash, created_at, updated_at
- [x] Email has unique constraint and index
- [x] Password reset fields: reset_token, reset_token_expires
- [x] Schema documented in DECISIONS.md

## Context Files
- src/db/migrations/ (existing migration patterns)
- src/db/schema.ts (if using Drizzle/Prisma)

## Outputs
- Created: `src/db/migrations/001_create_users_table.sql`
- Created: `src/models/user.ts`
- Modified: `src/db/schema.ts`
- Decisions: DEC-001 (UUID vs auto-increment), DEC-002 (password hashing algorithm)

---

## Work Log

### 2025-01-16 10:00 - Started
Reading existing migration patterns in src/db/migrations/. Project uses raw SQL migrations with a custom runner. Will follow existing naming convention.

### 2025-01-16 10:15 - Progress
Created migration file. Decided to use UUID for user IDs instead of auto-increment for better distributed systems compatibility. Documenting in DECISIONS.md.

### 2025-01-16 10:30 - Progress  
Added password reset fields. Considered separate table but keeping in users table for simplicity since it's 1:1. Added index on reset_token for lookup performance.

### 2025-01-16 10:45 - Complete
Migration tested locally. Created TypeScript model with proper types. All acceptance criteria met.

Summary:
- Created users table with UUID primary key
- Added email unique constraint + index
- Added password reset token fields with expiry
- Created TypeScript User model
- Documented 2 architectural decisions
