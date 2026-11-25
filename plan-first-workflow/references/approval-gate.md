# Phase 2: STOP until explicit user approval

Do not write tests or implementation code until the user explicitly approves the current plan: the goal and scope, the acceptance demo and its expected outcomes, any cross-module contract or architecture changes, and the chosen approach in light of the rejected alternatives. Approval covers the initial plan as amended by the proposed timeline entries presented for this review. An open draft PR, passing checks, silence, or a request for revisions is not approval. Keep the draft PR open; do not mark it ready or merge it.

If review changes the proposal, preserve the original plan and append the revised design, demo, and expected result as applicable to the [timeline](feature-record.md). Push that documentation-only revision to the same bookmark and draft PR, then stop again for approval of the revised plan. Approval alone does not need a timeline entry.

Only after explicit approval, continue to [implementation](implement.md) on the same PR.
