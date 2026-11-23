---
name: frontend-development
description: Build and review production-quality frontend features covering accessibility, responsive behavior, state, performance, security, and tests.
---

# Frontend Development

Use for browser-facing UI and client-side application work. Inspect the existing framework, design system, supported browsers, accessibility target, and testing conventions before choosing patterns or dependencies.

For implementation, follow `../solid-tdd-craft/SKILL.md` and its Restrictions, with `../tdd-workflow/SKILL.md` for behavioral changes. Keep review requests read-only.

## Implementation checks

1. Use semantic HTML and the established component system. Support keyboard operation, visible focus, meaningful labels, accessible names, sufficient contrast, and appropriate screen-reader announcements.
2. Make layouts usable across supported viewports, input methods, and zoom settings. Respect reduced-motion preferences and project localization, date, number, and text-direction requirements.
3. Model loading, success, empty, validation, and failure states. Keep state as local as practical; avoid duplicate sources of truth and synchronize server data using established cache/invalidation patterns.
4. Handle network failures, cancellation, stale responses, and repeated submissions. Validate on the server as well as the client; client checks improve UX but are not a security boundary.
5. Rely on framework output escaping. Avoid unsafe HTML injection, unsafe URL handling, and exposing secrets or privileged decisions in client code. Follow the application's CSP, session, and CSRF protections.
6. Keep bundles and rendering work proportional to the feature. Measure before optimizing; follow project performance budgets, load expensive code or media only when needed, and avoid unnecessary re-renders and large dependencies.
7. Test user-visible behavior with focused component and interaction tests. Cover keyboard and assistive-technology-relevant semantics, errors, responsive states, and critical end-to-end journeys using the project's existing tools.
8. Wire new components into the real route or screen, with navigation and permission behavior matching the application. Keep URLs, deep links, back/forward navigation, and refresh behavior correct where affected; a standalone component test does not prove integration.
9. Preserve form input on recoverable errors, associate field errors with their controls, and prevent unintended duplicate writes. Manage focus after navigation, dialogs, and validation failures; avoid inaccessible custom controls when native ones suffice.
10. Clean up subscriptions, timers, and listeners. For server-rendered applications, keep browser-only APIs out of server execution, avoid hydration mismatches, and prevent per-user data leaking through shared caches. Treat browser storage as exposed client data, not a safe place for secrets.
11. Scope cached data to the current user and tenant; invalidate or clear affected data on logout, account/tenant switch, and permission changes. Prevent an earlier request from repopulating a new session with stale private data.
12. Reconcile optimistic changes with the authoritative server result. Roll back or refresh after rejection; distinguish a confirmed failure from an unknown write outcome after a timeout. Disabling a button is not server-side idempotency, and cancellation does not prove a write was undone.

## Performance checks (when affected)

- Measure the changed journey using a production build on representative supported devices, viewports, and network/CPU conditions. Inspect network waterfalls, request chains, transferred bytes, JavaScript execution, long tasks, and rendering work before selecting an optimization.
- Assess Largest Contentful Paint (LCP), Interaction to Next Paint (INP), and Cumulative Layout Shift (CLS) where relevant, along with route transitions and the actual interaction being changed. Distinguish controlled laboratory measurements from authorized real-user field measurements; a lab score or proxy metric does not establish field performance.
- Check responsive image sizing, reserved media dimensions, font loading, and render-blocking resources. Defer noncritical resources, but do not blindly lazy-load the likely LCP image or preload everything. Use list virtualization or memoization only when measurements justify it, preserving accessibility and correctness.
- Verify HTTP/CDN/browser cache policy, cache keys, revalidation, and invalidation for changed resources. Private responses must not enter shared caches. Where service workers or long-lived tabs are used, check stale assets, version overlap, and update recovery without losing user input.
- Use the performance evidence protocol in `../production-readiness/SKILL.md`. Compare bundle and journey measurements against a baseline and agreed budgets; preserve functionality and accessibility. Report unavailable field/device checks instead of claiming universal improvement.

## Verification evidence

- Confirm the requested behavior first with a failing test, then run affected interaction tests and project lint, type-check, and build checks.
- Exercise the integrated screen in supported browsers at relevant viewport and zoom settings; include keyboard navigation, loading/error recovery, and the changed user journey. Report manual checks that were unavailable.
- Use automated accessibility checks plus relevant manual checks; automated scans do not establish full conformance. Compare performance with the project's actual budgets and representative conditions, including bundle growth and layout stability when affected; do not invent universal thresholds.
- For full-stack features, use `../backend-development/SKILL.md` for server behavior and verify the client/server contract. Do not substitute mocked success for an unavailable integration check.
- Where affected, test account/tenant changes with requests in flight, optimistic rejection, and a write whose response is lost. Verify the rendered result and persisted outcome through the actual screen/API boundary, not only callback invocations or snapshots.

## Review limits

- Do not invent visual requirements when no design is supplied; match existing patterns and call out unresolved product decisions.
- Do not claim accessibility or performance compliance from source inspection alone. Name the checks or manual assistive-technology/browser tests not performed.
