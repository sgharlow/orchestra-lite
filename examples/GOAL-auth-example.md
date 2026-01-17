# Goal: User Authentication System

## Description
Build a complete JWT-based authentication system for our web application. Users should be able to register with email and password, log in to receive access tokens, and reset forgotten passwords via email. The system should follow security best practices and integrate cleanly with our existing Express.js backend.

This is the foundation for all future user-related features, so the implementation needs to be solid and well-tested.

## Acceptance Criteria
- [ ] Users can register with email and password (unique email enforced)
- [ ] Passwords are hashed securely before storage
- [ ] Users can log in and receive a JWT access token
- [ ] JWT tokens expire after 1 hour and can be refreshed
- [ ] Invalid login attempts return appropriate error messages (without revealing if email exists)
- [ ] Password reset emails are sent with secure one-time tokens
- [ ] Password reset tokens expire after 15 minutes
- [ ] All endpoints have input validation
- [ ] All endpoints have unit and integration tests
- [ ] API documentation is complete

## Scope

### In Scope
- User registration endpoint (POST /api/auth/register)
- Login endpoint (POST /api/auth/login)
- Token refresh endpoint (POST /api/auth/refresh)
- Password reset request (POST /api/auth/forgot-password)
- Password reset completion (POST /api/auth/reset-password)
- User table/model with proper schema
- JWT token generation and validation middleware
- Password hashing utilities
- Email sending integration for password reset
- Input validation middleware
- Unit tests for all services
- Integration tests for all endpoints

### Out of Scope
- OAuth/social login (future phase)
- Two-factor authentication (future phase)
- Session management (using stateless JWT only)
- User profile management (separate feature)
- Admin user management UI
- Rate limiting (will be added as infrastructure layer)

## Technical Constraints
- Must use existing Express.js application structure
- Must use PostgreSQL database (existing connection)
- Must use existing email service (SendGrid already configured)
- JWT library: jsonwebtoken
- Password hashing: bcrypt with cost factor 12
- Validation: Zod schemas
- Testing: Jest + Supertest
