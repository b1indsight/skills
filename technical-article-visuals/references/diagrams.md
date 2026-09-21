# Flowcharts, Architecture Diagrams, and Structural Diagrams

Use this module for flowcharts, architecture diagrams, and structural diagrams. Follow the [main skill](../SKILL.md), then apply this module's task prompt, guidance for nodes and relationships, implementation requirements, and acceptance checks.

## Task Prompt

Fill in the placeholders below. Resolve unspecified optional fields according to the reader goal and the figure's size in the article.

```text
Apply the technical-article-visuals main skill and its flowchart and architecture diagram module to create a diagram for a technical article.

Source content and evidence: {article excerpts, technical descriptions, code, or existing diagrams, with paths and relevant sections}
Primary reader goal: {the process, component responsibilities, system boundaries, or interactions readers need to understand}
Content scope: {objects to show, scope boundaries, and necessary conditions}
Diagram type (optional): {flowchart, architecture diagram, or structural diagram; choose according to the goal if unspecified}
Article context (optional): {column width, language, existing visual guidelines}
Output directory: {output directory}
Static export requirements (optional): {SVG, PNG, and required dimensions}

Use nodes, groups, and connections to express supported technical relationships around the reader goal. Clarify missing information when it affects meaning, and label necessary assumptions explicitly.
Keep nodes focused on names and necessary brief responsibility descriptions. Apply this module's alignment and color guidance; place implementation details in the caption as appropriate for the reader goal.
Prefer HTML with inline SVG, keeping text, structure, connections, and styles editable. Export static images as needed.
Render and inspect the figure at its actual size in the article. Deliver source files, viewable output, and a short caption.
Briefly explain the diagram type and layout choices. Separately check whether the figure conveys the information needed for the reader goal and whether readers can understand it easily.
```

## Choose the Structure and Define Relationships

- **Flowcharts** show how events progress. Include entry points, processing, decisions, outcomes, and return or exception paths as the content requires. Do not invent steps to complete a visual pattern. Label decision branches with their actual conditions; do not assume every decision has two outcomes.
- **Architecture diagrams** show what a system contains, what each part does, and how the parts interact. Nodes represent components or entities; groups represent supported responsibility, deployment, or other boundaries. Position and arrows do not automatically imply execution order. Encode sequence only when the source establishes one.
- **Structural diagrams** show composition, containment, dependencies, mappings, or similar relationships. First choose which relationships need explanation; do not turn every connection into a process arrow. Nesting can express containment; use lines without arrows for relationships with no direction.
- When a diagram contains multiple relationship types, make each line type's meaning clear. Do not mix data flow, control flow, calls, and dependencies without explanation. Add line styles or legends only when a distinction is needed.
- When a connection needs explanation, label its action, transferred content, or condition. Label both directions separately when their meanings differ and the distinction affects understanding.
- Identify the nodes and relationships before arranging the layout. Flows usually follow one main reading direction; organize architecture by responsibilities, layers, or boundaries. Choose a direction that serves the content, without distorting relationships to make the layout regular.
- Reduce crossings and long detours while keeping branches, merges, and return paths traceable. Complex content may be split into multiple diagrams with a clear reading relationship, rather than crowding unrelated details into one figure.

## Node Text and Alignment

- Node names should accurately correspond to the source and be easy to recognize. Add a brief responsibility description only when the name is insufficient.
- Keep technical details that serve the reader goal inside nodes, along with optionality and conditions that affect meaning. Include implementation details such as class names or low-level APIs only when they aid identification or explanation; place other necessary details in the article text or caption.
- Center short node text horizontally by default, with balanced space above and below. Long descriptions or lists may be left-aligned; use consistent alignment for peer nodes with similar text structures. Align group headings, legends, and connection labels according to their positions and associated elements.
- After content changes, adjust node sizes, padding, line spacing, and spacing between nodes, then check the reading order and connection positions. Use whitespace to support grouping and relationship tracing.

## Shapes and Colors

Visual reference: [flowchart reference](style-reference.png). Use its pale fills, thin lines, and grouping approach; choose the layout for the content. Replace its vivid blue and green boundaries and headings with low-saturation colors.

- In flowcharts, use rectangles for processing and diamonds for decisions by default. Rounded, dashed boundaries may distinguish regions; label each boundary to explain the grouping.
- Choose architecture containers and shapes according to their meaning. Color does not automatically represent execution stages or deployment boundaries. Give shapes, boundaries, and colors clear roles, and explain their meanings when needed.
- Assign colors by the responsibilities, processed entities, or boundaries that need to be distinguished. Explain the classification through names, groups, or a legend. Follow the main skill for hue, lightness, and text contrast.
- Connections may be straight, segmented, or curved. Keep arrow direction clear and labels near the corresponding relationships, without overlapping lines or node edges.

The first palette suits flowcharts that distinguish processing, decisions, entry points, and outcomes. The listed uses are default suggestions. Adjust either palette's color values and semantic mappings to the content, select colors as needed, and preserve low saturation and distinguishability.

| Color family | Fill | Stroke | Default flowchart use |
| --- | --- | --- | --- |
| Blue-gray | `#E1E9F2` | `#7B8FA8` | Processing nodes |
| Muted yellow | `#F2ECD9` | `#AA9968` | Decision nodes |
| Muted red | `#F0DEDB` | `#AA8079` | Entry nodes |
| Muted green | `#DFE9DD` | `#809777` | Outcome nodes |
| Neutral gray | `#F0F2F4` | `#8995A1` | Supporting notes |

The second palette suits architecture or structural diagrams that need clearer distinctions among component categories. Define the mapping between colors and responsibilities according to the content.

| Color family | Fill | Stroke |
| --- | --- | --- |
| Muted purple | `#DDD6E8` | `#85748E` |
| Blue-gray | `#CCDDE9` | `#66829B` |
| Muted green | `#D9E4D5` | `#7A9272` |
| Warm brown | `#EAD4BD` | `#A87F57` |
| Neutral gray | `#E9ECEF` | `#8C96A0` |

## HTML and SVG Implementation

- Default to HTML with inline SVG that opens directly in a browser. Keep the diagram itself independent for later export and embedding in articles.
- Use an SVG `viewBox` that covers all content and preserves proportions when scaled. Size text, nodes, and spacing for readability at the actual display size in the article.
- Keep SVG text, nodes, connections, and labels separately editable, with style parameters defined centrally. Short node text may use `text-anchor="middle"` to align with the node center; balance the space above and below the entire text block.
- After layout changes, check connection endpoints, spacing around boundaries, arrow positions, and text clipping.
- Use consistent arrow markers with accurate directions and targets. When lines cross regions, make crossings visually distinct from connections, without suggesting an unintended connection to a container border or another node.
- Render the HTML and inspect the actual image. When static images are needed, export from the same vector source and check text, line widths, arrows, and clipping.

## Deliverables and Specific Acceptance Checks

- Deliver HTML that opens successfully and its required resources, with SVG or PNG as requested. Use short filenames; explain necessary scope, conditions, sources, and assumptions in the caption.
- **Flow completeness**: Main paths within the diagram's scope are traceable, with clear branch conditions and return targets. Omitted details do not change the flow's meaning.
- **Architecture accuracy**: Component responsibilities, containment, and relationships across boundaries are supported. Arrows and spatial organization do not imply unsupported calls, data flows, or timing.
- **Readable relationships**: Node names, connection directions, conditions, and groups correspond clearly. Crossings, occlusion, and label placement do not create ambiguity.
- **Concise nodes**: Names are recognizable, and descriptions add necessary responsibilities and conditions. Simplification preserves essential meaning; alignment suits the text structure, with appropriate whitespace and spacing.
- **Distinct groups**: Categories that need distinction are clear at the actual display size in the article. Colors match the classification and do not imply unsupported execution stages or deployment boundaries.
- **Effective presentation**: The figure conveys the information needed for the reader goal, and the main path or core structure is easy to identify. Assess effective information density and reading efficiency separately as specified in the main skill.
- **Usable output**: HTML opens successfully, and text and graphics remain editable. Static exports match the HTML's content, layout, and styles. Apply the main skill's general acceptance checks to the remaining aspects.
