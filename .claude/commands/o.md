---
description: Shortcut alias for /orchestra — multi-agent task coordination (plan, work, done, stuck, status)
argument-hint: "[plan|replan|split|work|continue|next|done|stuck|drop|status|context|decide] [task-id]"
---

# /o [action]

Shortcut for `/orchestra`. Every `/o` invocation follows the full `/orchestra`
documentation — including its Preconditions & Failure Modes and each workflow's
verification steps — exactly as if `/orchestra [action]` had been typed.

## Quick Reference
```
/o plan      - Create tasks from goal
/o status    - Show progress
/o work      - Do next task
/o done ID   - Complete task
/o stuck ID  - Mark blocked
```

All `/orchestra` commands work with the `/o` prefix; see `orchestra.md` for the
complete command list and workflows.
