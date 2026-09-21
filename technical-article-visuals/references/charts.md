# Statistical Charts

Use this module for statistical charts showing comparisons, trends, distributions, and similar data. Follow the [main skill](../SKILL.md), then apply this module's task prompt, drawing requirements, and specific acceptance checks.

## Task Prompt

Replace the placeholders for the task and include any explicit requirements. Choose unspecified formats and dimensions to suit the article body.

```text
Create a statistical chart from {data file or source} for {article topic and audience}, with this reader goal: {reader goal}.
Follow the technical-article-visuals main skill and statistical charts module.
Choose the chart type and statistical definitions based on the reader goal and data, making the relevant information easy to understand or compare visually.
Include necessary statistical definitions, conditions, and sources in the accompanying caption. Use Python and retain a runnable plotting script.
Save the outputs to {output directory} in {image formats and display dimensions} suited to the article, using short filenames.
View the rendered chart and verify the data. Separately check whether the chart conveys the information needed for the reader goal and whether readers can easily understand and compare it.
```

For a timing comparison, the reader goal could be "Make the elapsed times of two versions easy to compare visually." Keep requirements explicitly set by the user or analytical question in the task prompt; choose unspecified statistics and chart types based on the reader goal and data.

## Data and Chart Selection

- Use Python for plotting and choose the library for the task. First verify the data sources, entity names, units, samples, and timing or analysis conditions.
- Choose the information, statistical definitions, and chart type based on the reader goal. When a summary is needed, calculate statistics from the relevant data and explain their meaning; when using existing summaries, verify their definitions. Show only data relevant to the goal, and do not treat example chart types as fixed choices.
- Keep scales and units comparable across entities. When bar length represents magnitude, make the baseline explicit to avoid exaggerating or understating differences; use a zero baseline for ordinary comparisons of nonnegative elapsed times. Clearly indicate nonlinear scales, truncation, or normalization.
- When using range or error indicators, state whether they represent the observed minimum and maximum, a quantile range, or another statistic, and verify them against the relevant data.
- Add numeric labels when readers need exact values or important details. If a label repeats a statistic already shown graphically, it should add value to the reader's understanding.

## Color and Layout

- For two series, consider deep blue `#496B86` and warm brown `#A47550`, with the lighter `#B5C5D2` and `#D4BBA7` for large fills. Adjust colors to keep saturation low and series clearly distinguishable, as required by the main skill.
- Follow the main skill's requirements for legend names and matching symbols, and explain the statistics or intervals actually shown.
- For comparison charts that need a combined explanation of series and statistical markers, prefer a horizontal, left-aligned legend below the plot area. Wrap it when space is limited, or choose another position to suit the content.
- Label axes with necessary names and units, retaining ticks and gridlines that aid comparison. Usually put sample sizes, test environments, methods, and sources in the caption; keep explanations needed to read the chart within the chart itself.

## Deliverables and Specific Acceptance Checks

- Deliver a runnable Python script, data files or references to data sources, dependencies and run commands, and the chart and caption. Export SVG, PNG, or other formats as needed, using short filenames such as `plot.py`, `figure.svg`, and `figure.png`.
- Verify that the chart's entities, summary values, ranges, units, and scales match the source data and statistical definitions. Check that no entities or conditions affecting the comparison are missing.
- View each chart at the intended article display size, checking series distinction, statistical markers, and legends. Apply the main skill's remaining acceptance checks. Report necessary assumptions, data limitations, and unfinished checks.
