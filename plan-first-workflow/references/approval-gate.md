# Phase 2: Review the draft before implementing

Wait for explicit user approval of the plan, including the acceptance scenario and any interface sketches. A passing automated review is not user approval. Keep the draft PR open and production code unchanged.

If review changes the proposal, append the amendment and any revised interface sketch to the [timeline](feature-record.md), adjust the acceptance test if affected, and update the same bookmark and draft PR. Route the push by [what it contains](jj-mechanics.md): test changes need the gate; plan-only amendments do not. Wait for approval of the revised scope. Approval alone does not need a timeline entry.

After approval, continue to [implementation](implement.md) on the same PR.
