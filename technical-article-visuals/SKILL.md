---
name: technical-article-visuals
description: Create or edit statistical charts, flowcharts, architecture diagrams, structural diagrams, and supporting conceptual icons for technical articles. Load the relevant drawing module and apply shared communication principles, visual specifications, workflow, and acceptance criteria.
---

# Technical Article Visuals and Icons

This file defines shared principles, style, workflow, and acceptance criteria for article figures. Modules provide task prompts and specific rules; read them as needed. Explicit user requirements take precedence. Follow existing article conventions and use this skill for unspecified details.

## 1. Modules and Drawing Methods

Read the module for the task type. If a task includes several types of figures, apply each relevant module.

| Task | Drawing method | Module |
| --- | --- | --- |
| Statistical charts for comparisons, trends, distributions, and other data | Plot with Python | [Statistical charts](references/charts.md) |
| Flowcharts, architecture diagrams, and structural diagrams | Prefer vector graphics displayed in HTML, such as inline SVG | [Flowcharts and architecture diagrams](references/diagrams.md) |

- Fill in the module's task prompt with the reader goal, inputs, and deliverables.
- Use AI image generation for illustrations or textures. Draw precise technical relationships with tools that provide explicit control over geometry and layout.
- Supporting conceptual icons follow these shared requirements. Use one consistent icon system that matches the surrounding figures.

## 2. Visual Style

- Design for embedding in article text. Default to a flat style with a white background, light fills, and thin lines. Give the main graphic most of the canvas.
- Establish three information levels: the graphic conveys data, structure, and relationships; labels, legends, and axes help readers interpret it; the caption supplies context and conditions. Draw attention to the graphic first, with supporting information available as needed.
- Prefer captions for figure titles, background, data dates, and sources. Keep necessary labels, legends, axis names and units, panel labels, and short titles inside the figure. Omit slide-style headlines, branded headers, date badges, and long footers by default.
- Always use low-saturation colors, including fills, strokes, group headings, and accents.

## 3. Drawing Principles

These principles apply to charts, flowcharts, architecture diagrams, structural diagrams, and icons.

1. **Organize around the reader goal**: Establish what readers need to understand, then choose what to retain and which relationships to emphasize. Let that goal guide the visual form and layout.
2. **Let graphics do the explaining**: Use position, size, shape, grouping, and connections to convey meaning visually. Use text to name, qualify, and supplement.
3. **Increase effective information density**: Effective information density is the amount of distinct information relevant to the reader goal that a graphic clearly conveys within a given display area. Use space efficiently while preserving readability; added elements should contribute useful facts, relationships, or necessary details.
4. **Avoid repetition without added value**: Give every visual element a clear role. Once information is adequately conveyed, additional color, marks, text, or decoration needs its own justification.
5. **Establish a clear visual hierarchy**: Make important information visible first, group related content, and provide an easy reading order. Use emphasis, spacing, and whitespace to reflect importance and relationships.
6. **Stay consistent while preserving distinctions**: Use consistent visual language for the same meaning and sufficient visual differences for different meanings. Changes in color, lines, and shapes should have a semantic basis.
7. **Simplify form without changing meaning**: Omit details or compress structure only while preserving the relationships and conditions needed for understanding. Proportions, directions, connections, and groupings must not imply unsupported facts.

Reading efficiency concerns how easily readers understand and compare information; assess it separately from information density. Repeated representations of the same information do not count as additional information. Filled area and mark counts do not measure information density; figures conveying the same information can differ in reading efficiency.

## 4. Visual Specifications

- Default to a white background `#FFFFFF`, dark gray text `#2F343B`, and gray connectors and arrows `#5B6470`. Maintain lightness contrast for text and key outlines.
- Use soft fills and darker colors for thin lines and small marks. Choose as few colors as the semantics allow, with clear hue or lightness differences between categories that need distinction. Add labels, shapes, or line styles when needed. Group boundaries and supporting icons use the corresponding color family; see the modules for palettes.
- Use specific object or series names in legends and explain the necessary colors, line styles, and marks. Legend symbols must match their appearance in the figure.
- Text inside the figure identifies objects, explains relationships, and qualifies meaning. Place background, implementation, and derivation details in the article or caption according to the reader goal.
- Keep supporting information near the relevant graphic, grouped by meaning and arranged compactly. Align boundaries and baselines, and use consistent spacing so alignment and whitespace support grouping and reading order. Choose alignment to suit the content.
- Set canvas proportions, margins, and content sizes for the article column width. Maintain the prominence and readability of the main graphic, with moderate size differences between titles and annotations. When space is tight, shorten wording and adjust grouping and layout while preserving necessary meaning.
- Define reusable parameters for the canvas, margins, fonts, type sizes, line widths, arrows, corner radii, spacing, and icon grids. Keep typography consistent across Chinese, English, and code labels. Reuse these parameters within an article and preserve established conventions when editing existing figures.

## 5. Workflow

1. Understand the content and use case, and identify the question readers need answered.
2. Extract key information, relationships, and necessary conditions. Identify distinct information and repeated representations. Clarify missing technical relationships or explicitly label them as assumptions.
3. Choose drawing methods and visual structures that serve the reader goal. Assign content to the main graphic, reading aids, and caption. Arrange reading order, emphasis, legends, and alignment for the article column width.
4. Determine the necessary text, then draw using the visual specifications. Coordinate content sizes, alignment, and semantic colors, keeping figures and supporting icons consistent within the article.
5. Render and inspect at the intended article display size. Check whether the figure conveys the information required by the reader goal and whether readers can easily understand and compare it. Correct any issues.
6. Deliver editable sources, viewable outputs, and any required static exports according to the module. Include definitions, conditions, sources, and other details that affect interpretation in the caption. State necessary assumptions and any checks not completed.

Complete routine tasks directly. Ask for clarification only when missing information affects technical meaning or a core style choice. When editing a figure, focus on the requested changes.

## 6. Acceptance Criteria

- **Meaning**: Key information, relationships, and conditions are supported by sources and remain accurate after simplification. Proportions, directions, connections, and groupings imply no unsupported facts. Apply the module's specific semantic checks.
- **Communication and hierarchy**: The figure answers the intended question and conveys key meaning visually. Readers can easily understand and compare the information. Organization, reading order, and emphasis are clear, with distinct levels for the main graphic, reading aids, and background information.
- **Information and density**: The figure clearly conveys the distinct information required by the reader goal within a reasonable area. Added elements contribute information, without redundant repetition. Assess reading efficiency separately under "Communication and hierarchy."
- **Legend and layout**: Legend labels are clear, symbols match the figure, and key visual encodings are understandable. Supporting information is grouped nearby; boundaries, baselines, and spacing are coordinated. Whitespace supports grouping and reading order, and the main graphic occupies an appropriate share of the canvas.
- **Readability in the article**: At the intended article width, text, thin lines, marks, icons, and legends remain legible without unintended overlap or clipping. Text detail suits the reader goal, and annotations plus the caption provide what readers need to interpret the figure.
- **Style and consistency**: Fills, strokes, group headings, and accents all use low-saturation colors. Text and key outlines remain clear. The same meaning uses consistent visual encoding, and important differences are easy to distinguish. Fonts, colors, lines, arrows, and icons follow a consistent system.
- **Delivery**: Required outputs are complete and runnable or viewable. Dimensions and backgrounds suit the intended use, sources are editable, and actual outputs have been inspected. Inspect static exports whenever they are required.
