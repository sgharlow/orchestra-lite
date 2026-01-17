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
3. The task's Context Files section

This prevents context-blind mistakes and maintains consistency.
