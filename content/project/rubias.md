+++
# Date this page was created.
date = "2016-06-27"

# Project title.
title = "rubias"

# Project summary to display on homepage.
summary = "Computationally efficient genetic stock identification in the tidyverse."

# Optional image to display on homepage (relative to `static/img/` folder).
image_preview = "gsi_dag.png"

# Tags: can be used for filtering projects.
# Example: `tags = ["machine-learning", "deep-learning"]`
tags = []

# Optional external URL for project (replaces project detail page).
external_link = "https://github.com/eriqande/rubias"

# Does the project detail page use math formatting?
math = false

# Optional featured image (relative to `static/img/` folder).
[header]
image = ""
caption = "The sample DAG underlying the basic GSI model"

+++

`rubias` is an R package for doing genetic stock identification in a tidy fashion.
This started off as a project to correct some known biases in reporting unit proportion
estimation, and to implement a hierarchical multivariate Balding-Nicholls model 
as a prior for allele frequencies.  The former didn't pan out and the latter didn't 
produce any benefit to warrant its inclusions.  But my Hollings Scholar, Ben Moran,
was not to be deterred, and the two of us put together this package.

The package currently lives at the [rubias GitHub site](https://github.com/eriqande/rubias).
The paper we have nearly finished for it, to be submitted to the Canadian Journal of
Fisheries and Aquatic Sciences, is available [here](https://github.com/eriqande/bh-reporting-units-doc).

This package is envisioned as a purely R-based replacement for [gsi_sim](https://github.com/eriqande/gsi_sim).