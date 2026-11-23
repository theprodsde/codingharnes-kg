---
name: solid-design
description: Apply SOLID, object-oriented design, and dependency-boundary principles while implementing or refactoring software.
---

# SOLID and Object Design

For implementation, follow `../solid-tdd-craft/SKILL.md` and its Restrictions, preserving behavior through `../tdd-workflow/SKILL.md`. Keep review requests read-only.

## SOLID

- **Single Responsibility:** keep one reason to change per class or module.
- **Open/Closed:** use stable extension seams where variation exists; a simple conditional over a closed set does not automatically need polymorphism.
- **Liskov Substitution:** subtypes honor their base contracts without stronger preconditions or surprising behavior.
- **Interface Segregation:** keep interfaces small and specific to their clients.
- **Dependency Inversion:** keep high-level policy independent of infrastructure details; inject I/O dependencies through appropriate boundaries.

## Object design

- Encapsulate state and expose behavior; avoid public setters unless required by the API.
- Prefer composition. Use inheritance only for a genuine substitutable “is-a” relationship and keep hierarchies shallow.
- Prefer immutable value objects for domain concepts that have validation or identity rules.
- Prefer polymorphism or a clear strategy abstraction when behavior varies by type; avoid abstractions that tests do not require.
- Keep domain logic independent of databases, HTTP, files, clocks, and other infrastructure.
- Keep dependencies flowing toward policy and use clear boundaries between domain, application, and infrastructure code.

Apply the project's established architecture first. Introduce an abstraction only when it improves a real seam or behavior under test.

## Verification and limits

- Apply these principles to functions and modules as well as classes; do not force object-oriented layers into a functional or framework-led codebase.
- Check affected dependency direction, callers, and contract behavior. Use existing architecture checks where present and focused behavior/contract tests for changed seams.
- Verify substituted implementations preserve observable outcomes, errors, and invariants, not only method signatures. Do not introduce an interface for every class or a factory for every constructor.
- Keep the new implementation reachable from the real composition root. Report the concrete responsibility or dependency problem solved rather than claiming SOLID compliance from a class diagram.
