#!/bin/bash
# Orchestra Lite - Multi-Agent Claude Code Coordination
# Initialize in your project directory

set -e

echo "🎭 Initializing Orchestra Lite..."
echo ""

# Create directory structure
mkdir -p .orchestra/tasks
mkdir -p .orchestra/done
mkdir -p .claude/commands

# ============================================================================
# GOAL.md - Define what you're building
# ============================================================================
cat > .orchestra/GOAL.md << 'EOF'
# Goal: [Your Goal Title]

## Description
[Describe what you're building in 2-3 paragraphs. Be specific about the end result.]

## Acceptance Criteria
- [ ] Criterion 1: [Specific, verifiable outcome]
- [ ] Criterion 2: [Specific, verifiable outcome]
- [ ] Criterion 3: [Specific, verifiable outcome]

## Scope

### In Scope
- [Feature/capability 1]
- [Feature/capability 2]

### Out of Scope
- [What we're NOT building]
- [Future work to defer]

## Technical Constraints
- [Any technical requirements or limitations]
- [Required technologies, patterns, etc.]
EOF

# ============================================================================
# PLAN.md - High-level phases
# ============================================================================
cat > .orchestra/PLAN.md << 'EOF'
# Plan

## Current Phase
Phase 1: [Phase Name]

## Phases

### Phase 1: [Foundation/Setup]
- [ ] Task group 1
- [ ] Task group 2

### Phase 2: [Core Implementation]
- [ ] Task group 3
- [ ] Task group 4

### Phase 3: [Integration/Polish]
- [ ] Task group 5
- [ ] Final testing

## Notes
[Any planning notes, open questions, or considerations]
EOF

# ============================================================================
# TASKS.md - The task board
# ============================================================================
cat > .orchestra/TASKS.md << 'EOF'
# Tasks

> Last updated: [timestamp]
> Progress: 0/0 complete

## Ready
<!-- Tasks ready to be claimed -->
<!-- Format: - [ ] `ID` Task name -->

## In Progress
<!-- Tasks currently being worked on -->
<!-- Format: - [ ] `ID` Task name (task/ID) -->

## Done
<!-- Completed tasks -->
<!-- Format: - [x] `ID` Task name ✓ -->

## Blocked
<!-- Tasks waiting on dependencies or external blockers -->
<!-- Format: - [ ] `ID` Task name (waiting: 001, 002) -->
<!-- Format: - [ ] `ID` Task name (blocked: reason) -->
EOF

# ============================================================================
# DECISIONS.md - Architectural decision log
# ============================================================================
cat > .orchestra/DECISIONS.md << 'EOF'
# Architectural Decisions

> This log captures important technical decisions for context across all agents.
> Every non-trivial choice should be documented here.

<!--
## Template

### DEC-XXX: [Decision Title]
**Date:** YYYY-MM-DD
**Task:** [Related task ID or "Planning"]
**Status:** Decided | Superseded by DEC-YYY

**Context:**
[Why did this decision need to be made?]

**Decision:**
[What was decided?]

**Rationale:**
[Why this choice over alternatives?]

**Alternatives Considered:**
- Option A: [Description] - [Why rejected]
- Option B: [Description] - [Why rejected]

**Consequences:**
- [Impact on other parts of the system]
- [Technical debt or future considerations]
-->

## Decisions

(No decisions recorded yet)
EOF

# ============================================================================
# Task template
# ============================================================================
cat > .orchestra/tasks/_TEMPLATE.md << 'EOF'
# Task XXX: [Task Title]

## Metadata
| Field | Value |
|-------|-------|
| **ID** | XXX |
| **Status** | ready / in_progress / done / blocked |
| **Branch** | task/XXX |
| **Assigned** | |
| **Depends** | [comma-separated task IDs, or "none"] |
| **Blocked-By** | [if status is blocked, explain why] |
| **Estimated** | [30-120 min] |

## Inputs
<!-- Files and artifacts from dependencies that this task needs -->
- [File or artifact from dependency]
- [Decision reference if relevant]

## Description
[Clear description of what needs to be done. Be specific.]

## Acceptance Criteria
- [ ] [Specific, verifiable criterion 1]
- [ ] [Specific, verifiable criterion 2]
- [ ] [Specific, verifiable criterion 3]

## Context Files
<!-- Existing files to read for context before starting -->
- [path/to/relevant/file.ts]

## Outputs
<!-- Filled in when complete -->
- Created: [files created]
- Modified: [files modified]
- Decisions: [any decisions made, reference DEC-XXX]

---

## Work Log
<!-- Append progress here while working -->

### [YYYY-MM-DD HH:MM] - Started
[Initial notes]

### [YYYY-MM-DD HH:MM] - Progress
[Progress update]

### [YYYY-MM-DD HH:MM] - Complete
[Summary of what was done]
EOF

# ============================================================================
# Main orchestra command
# ============================================================================
cat > .claude/commands/orchestra.md << 'EOF'
# /orchestra [action]

Multi-agent coordination system for parallel development.

## Quick Reference
```
/orchestra plan      - Create/update tasks from goal
/orchestra status    - Show progress and blockers
/orchestra work      - Claim and complete next task
/orchestra done ID   - Mark task complete
/orchestra stuck ID  - Mark task blocked
```

## Worker Identity

**Your identity is determined by your current git branch.**

| Current Branch | Your Status |
|---------------|-------------|
| `main` | Not assigned to any task |
| `task/XXX` | You own task XXX |

To check your identity:
```bash
git branch --show-current
```

This branch-based identity is used for:
- Knowing which task is "yours" in `/orchestra continue`
- Preventing duplicate claims (if branch exists, task is taken)
- Tracking who is working on what

## Planning Commands

### /orchestra plan
Analyze GOAL.md and create/update tasks. Safe to run multiple times.

**Workflow:**
1. Read `.orchestra/GOAL.md` for requirements
2. Read `.orchestra/TASKS.md` for current state
3. Read `.orchestra/DECISIONS.md` for context
4. Identify what work is needed that isn't covered by existing tasks
5. For each new task needed:
   - Create file `.orchestra/tasks/XXX-short-name.md` using template
   - Use next available ID (001, 002, etc.)
   - Identify dependencies on other tasks
6. Update `.orchestra/TASKS.md`:
   - Add new tasks to appropriate section (Ready or Blocked)
   - Update progress count
7. Update `.orchestra/PLAN.md` if phases change
8. Report summary of changes

**Output format:**
```
📋 Planning Summary

New tasks created:
- 001: [Task name]
- 002: [Task name] (depends: 001)

Current state:
- Ready: N tasks
- Blocked: N tasks
- Total: N tasks

Suggested next action: [what to do next]
```

### /orchestra replan
Re-evaluate remaining work based on what's been learned.

1. Read completed tasks in `.orchestra/done/`
2. Read DECISIONS.md for context
3. Assess remaining tasks - still valid? sized correctly?
4. Propose adjustments (add, remove, split, re-sequence)
5. Apply changes with confirmation

### /orchestra split [task-id]
Break a large task into smaller subtasks.

**Workflow:**
```
1. READ the original task file

2. ANALYZE the work into 2-4 smaller pieces
   - Each piece should be independently completable
   - Identify if subtasks depend on each other

3. CREATE new task files:
   - Use IDs: [original]-a, [original]-b, etc. (e.g., 003a, 003b, 003c)
   - Each subtask INHERITS the original task's dependencies
   - If subtasks depend on each other, add those dependencies too
   - Copy relevant acceptance criteria to each subtask

4. UPDATE tasks that depended on the original:
   - Find all tasks where Depends includes [original-id]
   - Change their Depends to include ALL subtask IDs
   - Example: Task 007 depended on 003 → now depends on 003a, 003b, 003c

5. MARK original task as split:
   - Status: split
   - Add note in Description: "Split into: 003a, 003b, 003c"
   - Move to .orchestra/done/ (it's resolved by splitting)

6. UPDATE TASKS.md:
   - Remove original from its section
   - Add subtasks to Ready (if no inter-dependencies) or Blocked
   - Update task count

7. REPORT:
   Task [ID] split into:
   - [ID]a: [description]
   - [ID]b: [description]
   - [ID]c: [description]

   Tasks updated: [list of tasks whose dependencies changed]
```

## Working Commands

### /orchestra work
Claim and complete the next ready task.

**CRITICAL: Follow this workflow exactly**

**Phase 1 - Load Context (MANDATORY)**
```
1. Read `.orchestra/config.yaml` to get test_command and git settings
2. Read `.orchestra/DECISIONS.md` completely
3. Read `.orchestra/TASKS.md` to understand current state
4. Find the first task in "Ready" section (ordered by ID, lowest first)

   If NO tasks in Ready section:
   - Report: "No ready tasks available"
   - If Blocked section has tasks: "N tasks blocked - check dependencies or external blockers"
   - Suggest: `/orchestra status` to see full state
   - Suggest: `/orchestra plan` if goal work is incomplete
   - STOP here - do not proceed to Phase 2

5. Read that task file from `.orchestra/tasks/`
6. For each task in "Depends" field:
   - Read the completed task from `.orchestra/done/`
   - Note the Outputs section - these are your inputs
```

**Phase 2 - Claim Task**
```
1. Verify task is available:
   git branch -a | grep "task/[ID]"
   If branch exists → task already claimed, pick next Ready task

2. Git setup:
   git checkout main
   git pull origin main  (skip if no remote configured)
   git checkout -b task/[ID]

3. Update task file:
   - Status: ready → in_progress
   - Assigned: task/[ID]  (branch name is your identity)

4. Update TASKS.md:
   - Move task from "Ready" to "In Progress"
   - Format: - [ ] `ID` Task name (task/ID)
   - Update "Last updated:" timestamp
```

**Phase 3 - Do The Work**
```
1. Read Context Files listed in task
2. Read Input files/artifacts from dependencies
3. Implement according to Description
4. For each Acceptance Criterion:
   - Implement the requirement
   - Verify it works
   - Check the box in the task file
5. Update Work Log with progress
6. Make incremental git commits
7. If making architectural decisions:
   - Add to DECISIONS.md with next DEC-XXX number
   - Reference in task's Outputs section
```

**Phase 4 - Verify**
```
1. All acceptance criteria checked?
2. Run tests using test_command from config.yaml (e.g., npm test, pytest)
3. Output files listed in task actually exist?
4. Work log updated with progress?
```

**Phase 5 - Complete**
```
Run: /orchestra done [task-id]
```

### /orchestra work [task-id]
Claim a specific task by ID (must be in Ready state).

Same workflow as `/orchestra work` but skip task selection.

### /orchestra continue
Resume work on your in-progress task.

1. Detect your current task:
   ```bash
   git branch --show-current
   ```
   - If on `task/XXX` → you own task XXX, proceed to step 2
   - If on `main` → check "In Progress" section of TASKS.md:
     - If exactly one task in progress → offer to switch to that branch
     - If multiple tasks → ask user which to resume
     - If none → report "No tasks in progress"

2. Read `.orchestra/config.yaml` for settings
3. Read the task file from `.orchestra/tasks/`
4. Read Work Log to see where you left off
5. Read any new entries in DECISIONS.md since you started
6. Continue working
7. When done: `/orchestra done [task-id]`

### /orchestra next
Show recommended next task without claiming it.

1. Read TASKS.md
2. Find first Ready task
3. Show task summary and dependencies
4. Don't modify any files

## Completion Commands

### /orchestra done [task-id]
Mark a task as complete and handle all bookkeeping.

**Workflow:**
```
0. READ CONFIG:
   Read `.orchestra/config.yaml` to get:
   - test_command (for verification)
   - git.main_branch (default: "main")
   - git.auto_push (default: true)

1. VERIFY ownership:
   - Run `git branch --show-current`
   - Must be on task/[ID] branch, or task must be assigned to you

2. VERIFY completion:
   - All acceptance criteria checked in task file?
   - Output files listed actually exist?
   - Tests pass? Run: test_command from config.yaml
     (If test_command is empty or not defined, WARN user and skip tests)

   If any verification fails, report what's missing and STOP.

3. UPDATE task file:
   - Status: in_progress → done
   - Fill in Outputs section completely
   - Add final Work Log entry with summary

4. MOVE task file:
   mv .orchestra/tasks/[ID]-name.md .orchestra/done/

5. UPDATE TASKS.md:
   - Move task to "Done" section: - [x] `ID` Task name ✓
   - Update progress count (e.g., "3/8 complete")
   - Update "Last updated:" timestamp

6. UNBLOCK dependent tasks:
   - Read each task file in `.orchestra/tasks/` (these are non-done tasks)
   - For each file, check the "Depends" field in Metadata
   - If Depends includes the just-completed task ID:
     a. Get the task's FULL dependency list
     b. Check if ALL dependencies are now in "Done" section of TASKS.md
     c. If ALL done: move task from "Blocked" to "Ready" (maintain ID order)
     d. If NOT all done: task stays in "Blocked"

7. GIT cleanup:
   git add -A
   git commit -m "[ID] Complete: [task title]"
   git checkout [main_branch from config]

   # Check if remote exists
   If `git remote | grep -q origin`:
     git pull origin [main_branch]
     git merge task/[ID] --no-edit
     If config.git.auto_push is true:
       git push origin [main_branch]
   Else:
     git merge task/[ID] --no-edit

   git branch -d task/[ID]

8. REPORT:
   ✅ Task [ID] complete

   Unblocked tasks:
   - [ID]: [name] - now Ready

   Progress: X/Y complete (Z%)
   Next ready task: [ID]: [name]
```

### /orchestra stuck [task-id] [reason]
Mark a task as blocked by an external issue. Preserves branch for later resumption.

**Workflow:**
```
1. VERIFY you're on the task branch:
   git branch --show-current  # Should be task/[ID]

2. UPDATE task file:
   - Status: in_progress → blocked
   - Blocked-By: [reason]
   - Add Work Log entry: "[timestamp] - Blocked: [reason]"

3. UPDATE TASKS.md:
   - Move to "Blocked" section
   - Format: - [ ] `ID` Task name (blocked: [reason])
   - Update "Last updated:" timestamp

4. COMMIT progress and return to main:
   git add -A
   git commit -m "[ID] Blocked: [reason]"
   git checkout main
   # KEEP the branch - do NOT delete it

5. REPORT:
   ⏸️ Task [ID] blocked: [reason]

   Branch task/[ID] preserved with partial progress.

   To resume after blocker resolved:
     git checkout task/[ID]
     /orchestra continue

   Other ready tasks: [list from Ready section]
```

**Note:** The branch is preserved so work can resume later. When the blocker is resolved:
1. Run `git checkout task/[ID]` to return to the branch
2. Update task file: Status: blocked → in_progress, clear Blocked-By
3. Update TASKS.md: Move back to "In Progress"
4. Continue working with `/orchestra continue`

### /orchestra drop [task-id]
Unclaim a task without completing it. Preserves orchestration state, discards code changes.

**Workflow:**
```
1. VERIFY you're on the task branch:
   git branch --show-current  # Should be task/[ID]

2. DISCARD code changes (keep orchestration files):
   git stash  # Or: git checkout -- . (to discard)

3. SWITCH to main and delete task branch:
   git checkout main
   git branch -D task/[ID]

4. UPDATE task file in .orchestra/tasks/:
   - Status: in_progress → ready
   - Assigned: (clear)
   - Add Work Log entry: "[timestamp] - Dropped: [brief reason]"

5. UPDATE TASKS.md:
   - Move from "In Progress" to "Ready"
   - Update "Last updated:" timestamp

6. COMMIT the state change (on main):
   git add .orchestra/
   git commit -m "[ID] Drop: task unclaimed"

7. REPORT:
   Task [ID] returned to Ready state.
   Code changes discarded. Task available for re-claiming.
```

## Utility Commands

### /orchestra status
Show current state of all work.

**Output format:**
```
🎭 Orchestra Status
═══════════════════════════════════════

📎 Goal: [Title from GOAL.md]
📊 Progress: X/Y tasks complete (Z%)

## Ready (N)
   → 003: Create login endpoint (suggested next)
     005: Build user form

## In Progress (N)
   🔄 004: Implement auth service (task/004)

## Blocked (N)
   ⏸️ 006: Integration tests (waiting: 003, 004)
   ⏸️ 009: External API setup (blocked: waiting for API keys)

## Recently Completed
   ✓ 001: Design schema
   ✓ 002: Setup project

## Recent Decisions
   DEC-001: Using bcrypt for password hashing
   DEC-002: JWT tokens expire in 1 hour

## Blockers & Issues
   [Any stuck tasks with blocked: reason]
```

### /orchestra context
Show key context for starting work (recent decisions, patterns established).

1. Show last 5 decisions from DECISIONS.md
2. Show outputs from recently completed tasks
3. Show any patterns or conventions established

### /orchestra decide [topic]
Log an architectural decision.

1. Determine next DEC-XXX number
2. Prompt for: Context, Decision, Rationale, Alternatives
3. Append to DECISIONS.md in standard format
4. Report the decision ID

## Git Workflow Reference

### Check if remote exists
```bash
git remote | grep -q origin && echo "Remote exists" || echo "No remote"
```

### Starting a task
```bash
git checkout main
git pull origin main    # Skip if no remote
git checkout -b task/XXX
```

### During long tasks (sync with main)
```bash
# Only if remote exists:
git fetch origin main
git rebase origin/main
# or: git merge origin/main
```

### Completing a task
```bash
git checkout main
# If remote exists:
git pull origin main
git merge task/XXX --no-edit
git push origin main    # If auto_push enabled
# If no remote:
git merge task/XXX --no-edit
# Then:
git branch -d task/XXX
```

### If merge conflicts occur
```bash
# After git merge task/XXX shows conflicts:
# 1. Open conflicted files
# 2. Resolve conflicts manually
# 3. git add [resolved files]
# 4. git commit
# 5. git push origin main  (if remote exists and auto_push enabled)
```
EOF

# ============================================================================
# Quick reference command
# ============================================================================
cat > .claude/commands/o.md << 'EOF'
# /o [action]

Shortcut for /orchestra. See `/orchestra` for full documentation.

Common actions:
- `/o plan` - Create tasks
- `/o status` - Show progress
- `/o work` - Do next task
- `/o done ID` - Complete task
EOF

# ============================================================================
# CLAUDE.md additions (append to existing or create)
# ============================================================================
CLAUDE_ADDITION='
## Orchestra Lite - Multi-Agent Coordination

This project uses Orchestra Lite for coordinated parallel development.

### Quick Start
```
/orchestra plan    - Break down the goal into tasks
/orchestra work    - Claim and complete next task
/orchestra status  - Check progress
/orchestra done ID - Mark task complete
```

### Key Files
| File | Purpose |
|------|---------|
| `.orchestra/GOAL.md` | What we are building |
| `.orchestra/PLAN.md` | High-level phases |
| `.orchestra/TASKS.md` | Task board (Ready/In Progress/Done/Blocked) |
| `.orchestra/DECISIONS.md` | Architectural decisions log |
| `.orchestra/tasks/*.md` | Individual task details |
| `.orchestra/done/*.md` | Completed task files |

### Workflow Rules

1. **Always work on a branch**: `git checkout -b task/XXX`
2. **Load context first**: Read DECISIONS.md and dependency outputs before starting
3. **One task at a time**: Finish or drop before claiming another
4. **Update both files**: Task file AND TASKS.md stay in sync
5. **Log decisions**: Any non-trivial technical choice goes in DECISIONS.md
6. **Verify before done**: Check acceptance criteria and run tests

### Task Lifecycle
```
ready ──→ in_progress ──→ done
              │
              ↓
          blocked ──→ ready (when unblocked)
```

### Multi-Terminal Usage
```
Terminal 1 (Planning):     Terminal 2 (Worker):     Terminal 3 (Worker):
  /orchestra plan            /orchestra work          /orchestra work
  /orchestra status          /orchestra done 001      /orchestra done 002
  /orchestra replan          /orchestra work          /orchestra work
```

### Important Conventions

**Task IDs**: Three-digit numbers (001, 002, etc.)

**Branch naming**: `task/XXX` where XXX is the task ID

**Commit messages**: `[XXX] Description of change`

**Decision IDs**: `DEC-XXX` sequential numbering

### Context Loading (MANDATORY before work)

Before starting any task, you MUST read:
1. `.orchestra/DECISIONS.md` - All architectural decisions
2. `.orchestra/done/[dependency-ids].md` - Output from dependency tasks
3. The task'"'"'s Context Files section

This prevents context-blind mistakes and maintains consistency.
'

# Check if CLAUDE.md exists
if [ -f "CLAUDE.md" ]; then
    echo "$CLAUDE_ADDITION" >> CLAUDE.md
    echo "✓ Appended Orchestra section to existing CLAUDE.md"
else
    cat > CLAUDE.md << CLAUDEEOF
# Project: [Your Project Name]

## Overview
[Brief description of your project]

## Tech Stack
- [Technology 1]
- [Technology 2]

## Development Commands
\`\`\`bash
npm install    # Install dependencies
npm run dev    # Start dev server
npm test       # Run tests
\`\`\`
$CLAUDE_ADDITION
CLAUDEEOF
    echo "✓ Created CLAUDE.md with Orchestra section"
fi

# ============================================================================
# Config file
# ============================================================================
cat > .orchestra/config.yaml << 'EOF'
# Orchestra Lite Configuration

project: "My Project"

# Command to run tests (used by /orchestra done)
test_command: "npm test"

# Uncomment and customize if needed:
# test_command: "pytest"
# test_command: "go test ./..."
# test_command: "cargo test"

# Default task time estimate (minutes)
default_estimate: 60

# Git settings
git:
  main_branch: "main"
  auto_push: true
EOF

# ============================================================================
# .gitignore additions
# ============================================================================
if [ -f ".gitignore" ]; then
    if ! grep -q ".orchestra/temp" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# Orchestra Lite" >> .gitignore
        echo ".orchestra/temp/" >> .gitignore
    fi
else
    cat > .gitignore << 'EOF'
# Orchestra Lite
.orchestra/temp/
EOF
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "✅ Orchestra Lite initialized!"
echo ""
echo "📁 Created structure:"
echo "   .orchestra/"
echo "   ├── GOAL.md          ← Define your goal here"
echo "   ├── PLAN.md          ← High-level phases"
echo "   ├── TASKS.md         ← Task board"
echo "   ├── DECISIONS.md     ← Decision log"
echo "   ├── config.yaml      ← Settings"
echo "   ├── tasks/           ← Active task files"
echo "   │   └── _TEMPLATE.md"
echo "   └── done/            ← Completed tasks"
echo ""
echo "   .claude/commands/"
echo "   ├── orchestra.md     ← Main command"
echo "   └── o.md             ← Shortcut"
echo ""
echo "📋 Next steps:"
echo ""
echo "   1. Edit your goal:"
echo "      nano .orchestra/GOAL.md"
echo ""
echo "   2. Start Claude and create tasks:"
echo "      claude"
echo "      > /orchestra plan"
echo ""
echo "   3. Open another terminal and start working:"
echo "      claude"
echo "      > /orchestra work"
echo ""
echo "   4. Check progress anytime:"
echo "      > /orchestra status"
echo ""
echo "🎭 Happy orchestrating!"
