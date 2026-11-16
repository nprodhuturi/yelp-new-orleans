## AI Usage for Project 2

I used Claude as a coding assistant throughout this project, mostly for technical steps (importing, saving, file management, figures) rather than for deciding what the analysis should conclude. I checked every result against my own rendered output.

**1. Saving the filtered data as RDS files and estimating run time** - I asked Claude how to save the filtered New Orleans data as `.rds` files so I wouldn't have to re-import the huge JSON files every time, and how long the full import would take on my laptop. - I followed up with questions about how much disk space the extraction needed and whether I could delete the raw files afterward. This shaped my workflow: run the import once (about 20–30 minutes), save compressed `.rds` files, and start every later step from those files, which load in seconds.

**2. Creating the figures** - I asked Claude to help build the maps and charts with `ggplot2` and `sf`, including the neighborhood maps, the chart comparing raw ratings with reviewer-adjusted scores, and the final top 10 map. - After rendering, I looked at each image and asked for fixes where something was hard to read. The changes included zooming the maps to where the restaurants are, using `ggrepel` so labels don't overlap, and giving the locals-vs-visitors chart equal axes so the comparison is fair. Each figure is also saved as a `.png` in `figures/` so it shows on GitHub.

**3. A result that looked wrong after rendering** - I pasted my results table back into the chat. Claude noticed that every neighborhood had the same score (3.92) and a weight of 0.01, and explained that the method estimating neighborhood differences had pulled every neighborhood to the city average. - It replaced that method with a fixed, documented rule and added an ANOVA to test whether neighborhood matters at all.

**4. Checking my work against the assignment** - I asked whether the extra ideas fit the rubric, and then pasted the project instructions. - Claude found that my Step 7 didn't follow the required method (reviewer baselines within my category group, a 5-review threshold, all vs. selected reviewers, top 10 map), and rebuilt it.

**What I learned:** pasting real output back into the chat worked much better than asking it to "make it better." Giving it the actual rubric mattered most.
