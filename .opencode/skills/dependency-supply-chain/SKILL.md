---
name: dependency-supply-chain
description: Control dependency additions and upgrades, lockfiles, registries, build actions, containers, provenance, licenses, and supply-chain verification without bypassing repository safeguards.
---

# Dependencies and Supply Chain

Use for package manifests, lockfiles, build plugins, CI actions, base images, or external tooling changes. Follow `../solid-tdd-craft/SKILL.md` and its Restrictions. Reviews stay read-only; dependency installation can execute code and is not an inspection-only action.

## Before implementation

- Inspect the package manager/version, registry policy, lockfile, supported runtimes, CI permissions, and existing advisory/license/provenance tooling.
- Check whether an installed package or repository helper already meets the need. Obtain approval for new dependencies or tooling outside the explicitly requested scope.
- Verify the exact package identity, source, maintenance, license, runtime compatibility, and relevant transitive changes using approved sources. Do not equate popularity with safety.

## Implementation checks

1. Use the configured package manager to update manifests and lockfiles together. Keep resolution reproducible with existing frozen/locked installation controls; avoid unrelated dependency churn.
2. Follow repository pinning/integrity rules for build actions and base images. Record a concrete approved source/version, and preserve provenance, signatures, or SBOM generation where required.
3. Inspect install scripts, new registries, permissions, and native builds affected by the change before executing them. Use least-privilege CI credentials and preserve trust boundaries for untrusted pull requests.
4. Assess relevant advisories and license obligations against the actual resolved version and usage. Record evidence and the approved mitigation or exception process; do not treat an unavailable scanner as a clean scan.
5. Remove an obsolete dependency only after checking imports, runtime registration, build use, and generated artifacts. Verify the replacement is used by the application, not just added to its manifest.

## Restrictions

- Do not run arbitrary remote installation scripts, add unapproved registries, disable integrity/signature/TLS checks, or use force/ignore flags to bypass dependency safeguards.
- Do not remove lockfiles, hand-edit their integrity data, suppress advisories, waive licenses, or grant broad CI permissions to make a build pass.
- Do not install packages for speculative future use, globally install tools, or change other user profiles without explicit authorization.
- Do not upload private source, dependency inventories, artifacts, or credentials to external scanners without authorization. Do not publish packages or images as part of local validation.

## Verification gates

- Run relevant tests, type/build checks, and configured advisory/license checks after the change. Verify locked resolution with the existing CI workflow or an authorized isolated installation when required.
- Inspect manifest/lockfile diff for unintended packages, source changes, and permission expansion. Confirm supported runtime compatibility and the application's actual dependency usage.
- Required unresolved advisory, license, provenance, or compatibility gates block release readiness; only an authorized owner can accept a documented exception.
- Report versions, reasons, exact verification results, and remaining risks. Use `../deployment/SKILL.md` for pipeline/artifact rollout concerns.
