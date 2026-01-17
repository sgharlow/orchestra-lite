# Orchestra Lite

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/github/v/release/sgharlow/orchestra-lite)](https://github.com/sgharlow/orchestra-lite/releases)

**Simple multi-agent coordination for Claude Code**

Orchestra Lite lets you run multiple Claude Code instances in parallel, coordinating through simple markdown files and git branches. No databases, no daemons, no complexity.

## Philosophy

- **Files ARE the database** — Markdown and YAML, human-readable and git-trackable
- **Humans trigger agents** — You control when work happens, no runaway costs
- **Git IS the coordination** — Branches prevent conflicts naturally
- **Claude does the thinking** — You just organize and orchestrate

## Quick Start

### 1. Initialize in your project

```bash
curl -sL https://raw.githubusercontent.com/sgharlow/orchestra-lite/master/init-orchestra.sh | bash
# Or download and run: bash init-orchestra.sh
```

**Windows (Git Bash/MSYS2):** Use `source init-orchestra.sh` instead of `bash init-orchestra.sh`.

### 2. Define your goal

```bash
nano .orchestra/GOAL.md
```

Write what you're building, acceptance criteria, and scope.

### 3. Plan the work (Terminal 1)

```bash
claude
> /orchestra plan
```

Claude will break down your goal into tasks with dependencies.

### 4. Start working (Terminal 2)

```bash
claude
> /orchestra work
```

Claude claims the next available task, does the work, and marks it complete.

### 5. Parallelize (Terminal 3, optional)

```bash
claude
> /orchestra work
```

Another worker claims a different task. Git branches prevent conflicts.

### 6. Monitor progress (any terminal)

```
> /orchestra status
```

## Worker Identity

**Your identity is determined by your current git branch.**

| Current Branch | Your Status |
|---------------|-------------|
| `main` | Not assigned to any task |
| `task/XXX` | You own task XXX |

Check your identity: `git branch --show-current`

This means:
- No need for worker IDs or registration
- `/orchestra continue` knows which task is yours by checking your branch
- If a branch exists, that task is claimed

## Commands Reference

| Command | Description |
|---------|-------------|
| `/orchestra plan` | Create tasks from GOAL.md (safe to re-run) |
| `/orchestra status` | Show progress, ready tasks, blockers |
| `/orchestra work` | Claim and complete next ready task |
| `/orchestra work ID` | Claim specific task |
| `/orchestra done ID` | Mark task complete, unblock dependents |
| `/orchestra stuck ID` | Mark blocked, preserve branch for later |
| `/orchestra drop ID` | Unclaim task, discard code changes |
| `/orchestra continue` | Resume your in-progress task |
| `/orchestra replan` | Re-evaluate remaining work |
| `/orchestra split ID` | Break task into subtasks (003 → 003a, 003b) |
| `/orchestra context` | Show recent decisions and patterns |
| `/orchestra decide` | Log an architectural decision |

Shortcut: `/o` works the same as `/orchestra`

## File Structure

```
project/
├── .orchestra/
│   ├── GOAL.md          # What you're building
│   ├── PLAN.md          # High-level phases
│   ├── TASKS.md         # Task board (the "kanban")
│   ├── DECISIONS.md     # Architectural decisions log
│   ├── config.yaml      # Settings (test command, etc.)
│   ├── tasks/           # Active task files
│   │   ├── 001-design-schema.md
│   │   └── 002-implement-auth.md
│   └── done/            # Completed and split task files
│       └── 000-setup.md
│
├── .claude/commands/
│   ├── orchestra.md     # Main command definition
│   └── o.md             # Shortcut
│
└── CLAUDE.md            # Project context (includes Orchestra docs)
```

## TASKS.md Format

```markdown
# Tasks

> Last updated: 2025-01-16 14:30
> Progress: 2/8 complete (25%)

## Ready
- [ ] `003` Create login endpoint
- [ ] `004` Create registration endpoint

## In Progress
- [ ] `005` Implement token refresh (task/005)

## Done
- [x] `001` Design user database schema ✓
- [x] `002` Implement password hashing utilities ✓

## Blocked
- [ ] `006` Create password reset flow (waiting: 003, 004)
- [ ] `009` External API integration (blocked: waiting for API keys)
```

**Format notes:**
- Ready: `- [ ] \`ID\` Task name`
- In Progress: `- [ ] \`ID\` Task name (task/ID)`
- Done: `- [x] \`ID\` Task name ✓`
- Blocked by dependencies: `(waiting: 001, 002)`
- Blocked by external issue: `(blocked: reason)`

## Task Lifecycle

```
              ┌─────────────────────────────────────┐
              │                                     │
              ▼                                     │
┌─────────┐      ┌─────────────┐      ┌──────┐    │
│  ready  │ ───► │ in_progress │ ───► │ done │    │
└─────────┘      └─────────────┘      └──────┘    │
     ▲                  │                          │
     │                  ▼                          │
     │           ┌─────────┐                       │
     └────────── │ blocked │ ──────────────────────┘
                 └─────────┘
                (when unblocked)
```

**Additional states:**
- `split` — Task was broken into subtasks (moved to done/)

## Multi-Terminal Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                        Your Project                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Terminal 1 (Planning)    Terminal 2 (Worker)   Terminal 3      │
│  ┌──────────────────┐    ┌──────────────────┐  ┌────────────┐  │
│  │ > /orchestra plan│    │ > /orchestra work│  │ > /o work  │  │
│  │                  │    │                  │  │            │  │
│  │ Created 8 tasks  │    │ Claimed task 001 │  │ Claimed 002│  │
│  │ 5 ready, 3 block │    │ Working...       │  │ Working... │  │
│  │                  │    │                  │  │            │  │
│  │ > /o status      │    │ > /o done 001    │  │ > /o done  │  │
│  │                  │    │ ✓ Complete       │  │ ✓ Complete │  │
│  │ 2/8 complete     │    │ Unblocked: 003   │  │            │  │
│  └──────────────────┘    └──────────────────┘  └────────────┘  │
│                                                                  │
│         ┌──────────────────────────────────────────┐            │
│         │           .orchestra/TASKS.md            │            │
│         │  (shared state, updated by all agents)   │            │
│         └──────────────────────────────────────────┘            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## How Conflicts Are Avoided

1. **Each task = own git branch**
   ```bash
   git checkout -b task/001  # Worker 1
   git checkout -b task/002  # Worker 2 (different branch)
   ```

2. **Branch existence = claim check**
   - Before claiming, check if `task/XXX` branch exists
   - If it exists, task is already claimed — pick another

3. **Tasks are scoped to specific files**
   - Task 001 works on `src/db/schema.ts`
   - Task 002 works on `src/services/auth.ts`
   - No overlap

4. **Dependencies enforce ordering**
   - Task 003 depends on 001 → Can't start until 001 merges
   - Merge conflicts resolved before dependent work begins

5. **Human resolves edge cases**
   - If conflict occurs, human resolves during merge
   - Clear ownership via branch names

## Task File Format

```markdown
# Task 001: Design User Schema

## Metadata
| Field | Value |
|-------|-------|
| **ID** | 001 |
| **Status** | ready |
| **Branch** | task/001 |
| **Assigned** | task/001 |
| **Depends** | none |
| **Blocked-By** | |
| **Estimated** | 45 min |

## Inputs
- [Files from dependencies]

## Description
[What needs to be done]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Context Files
- [Files to read before starting]

## Outputs
[Filled when complete]

---
## Work Log
[Appended during work]
```

## Command Details

### /orchestra stuck
Marks a task as blocked by an external issue.

- **Branch is preserved** (not deleted)
- Partial work is committed before returning to main
- To resume later:
  ```bash
  git checkout task/[ID]
  /orchestra continue
  ```

### /orchestra drop
Unclaims a task without completing it.

- **Code changes are discarded** (or stashed)
- Task returns to Ready state
- Branch is deleted
- State change committed on main

### /orchestra split
Breaks a large task into smaller subtasks.

- Creates new IDs: `003a`, `003b`, `003c`
- Subtasks inherit original's dependencies
- Tasks that depended on original now depend on ALL subtasks
- Original marked as "split" and moved to done/

## Architectural Decisions

Every significant decision gets logged in `DECISIONS.md`:

```markdown
### DEC-001: Password Hashing Algorithm
**Date:** 2025-01-16
**Task:** 001
**Status:** Decided

**Context:**
Need to select a password hashing algorithm.

**Decision:** Use bcrypt with cost factor 12

**Rationale:** Industry standard, good security/performance balance

**Alternatives Considered:**
- Argon2: Less library support
- PBKDF2: Older, less GPU-resistant
```

This ensures all agents share context about why things are built the way they are.

## Configuration

`.orchestra/config.yaml`:

```yaml
project: "My Project"
test_command: "npm test"  # Run during /orchestra done (optional)

git:
  main_branch: "main"
  auto_push: true

default_estimate: 60  # minutes
```

**Note:** If `test_command` is not defined, tests are skipped with a warning.

## Tips for Best Results

### Planning
- Keep tasks small (30-60 minutes)
- Make acceptance criteria specific and verifiable
- Identify dependencies explicitly
- Re-run `/orchestra plan` as you learn more

### Working
- Always load context first (DECISIONS.md, dependency outputs)
- Update work log as you go
- Commit incrementally
- Run tests before marking done

### Coordinating
- Check `/orchestra status` frequently
- Use `/orchestra stuck` early if blocked (branch preserved!)
- Document decisions immediately

## Limitations (By Design)

| Feature | Status | Reason |
|---------|--------|--------|
| Autonomous loops | No | Human control, no runaway costs |
| Database | No | Files are simpler, git-trackable |
| Web dashboard | No | TASKS.md is the dashboard |
| Cost tracking | No | Use Anthropic dashboard |
| Auto-retry | No | Human decides on failures |
| Real-time sync | No | Pull-based via git |

## Troubleshooting

### "No ready tasks available"
- Check if all tasks are blocked or done
- Run `/orchestra status` to see the full state
- Run `/orchestra plan` if more work is needed

### "Task shows blocked but dependencies are done"
Run `/orchestra done [dep-id]` again — it auto-unblocks dependents by reading all task files.

### "Merge conflict when completing task"
```bash
git checkout main
git pull
git merge task/XXX
# Resolve conflicts manually
git add . && git commit
git push  # if auto_push enabled
```

### "Lost track of what I was working on"
```
> /orchestra continue
```
Detects your task from current branch, or shows in-progress tasks if on main.

### "Task is too big"
```
> /orchestra split [task-id]
```
Breaks it into subtasks (003 → 003a, 003b, 003c).

### "I need to abandon my current task"
```
> /orchestra drop [task-id]
```
Returns task to Ready, discards your code changes.

### "I'm blocked by something external"
```
> /orchestra stuck [task-id] "waiting for API keys"
```
Preserves your branch so you can resume later with `/orchestra continue`.

## Examples

See the `examples/` directory:
- `GOAL-auth-example.md` — A filled-out goal for user authentication
- `TASKS-example.md` — Task board with various states
- `task-001-example.md` — Completed task showing proper format
- `DECISIONS-example.md` — Several architectural decisions

## License

MIT — Use freely in your projects.
