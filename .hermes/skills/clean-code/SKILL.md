---
name: clean-code
description: Improve readability and maintainability when writing, refactoring, or reviewing code.
---

# Clean Code

For implementation, follow `../solid-tdd-craft/SKILL.md` and its Restrictions; for refactoring, preserve behavior with `../tdd-workflow/SKILL.md`. Review requests remain read-only.

Use the project's formatter, linter, and conventions first. If the project has no limits, use these as warning thresholds rather than reasons for mechanical refactoring:

| Measure | Guideline |
|---|---:|
| Function or method | 20 lines |
| Parameters | 3 |
| Nesting depth | 2 |
| Cyclomatic complexity | 10 |
| Class / source file | 200 / 300 lines |
| Line length | 120 characters |

- Choose names that reveal intent: verbs for operations, nouns for concepts, and `is` / `has` / `can` for booleans.
- Keep each function at one level of abstraction and avoid hidden side effects or boolean mode flags.
- Replace unexplained magic values with meaningful constants; validate external input at system boundaries.
- Surface specific errors instead of swallowing them or returning success-shaped fallbacks.
- Prefer removing duplication of knowledge, but do not invent an abstraction for one-off similarities; apply the Rule of Three.
- Build only what an acceptance criterion requires. Comments explain why, not what; remove commented-out code.
- Keep modules cohesive and within the project's conventions. Split when responsibilities or reasons to change are genuinely independent, not just to satisfy a line count.
- Preserve type safety and contracts. Prefer precise types, existing validation helpers, and explicit handling of optional values over unchecked casts or disabling diagnostics.
- Reuse existing utilities before adding new ones. Remove superseded code only within the requested scope and ensure replacements have real callers; do not leave parallel unused implementations.

## Verification

Run relevant behavior tests and the existing formatter, lint, and type checks for implementation changes. Treat the thresholds above as review prompts, not proof of quality. Report concrete maintainability improvements and any behavior or compatibility deviation instead of claiming that shorter code is automatically better.
