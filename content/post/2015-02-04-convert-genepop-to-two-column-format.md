---
title: Convert Genepop to two-column format
author: Eric C. Anderson
date: '2015-02-04'
slug: convert-genepop-to-two-column-format
categories: []
tags: []
---


People here at the SWFSC have started using stacks to process ddRad data.  They can output
data from stacks in genepop format, and sometimes the want to convert that into the format
that is useful for [slg_pipe](https://github.com/eriqande/slg_pipe.git).

I would typically have done that sort of thing using sed and awk, but I thought I would
give a whirl at doing it in R.  

Below is a function I wrote for Martha.  It doesn't do any error checking and it only applies
to the particular genepop format that Martha had...but that is what stacks spit out,
so it ought to work.  I'm sure it could break in myriad ways. 

Anyway, here it is.  I suppose I should really  put this in a gist...

```r
#' convert genepop format (as Martha has it) without much error checking
#' 
#' This is just a quick, and pretty ugly thing.
#'
#' @param infile name of the genepop infile
#' @param outfile name for the two-column format file you wnat to be produced
#' @param NUM Number of digits in the genepop format. 
#' @value This returns a list with the comment line from the genepop file that has been processed.
gpop2twocol <- function(infile, outfile = "two-col.txt", NUM = 2) {
  require(stringr)
  
  x <- readLines(infile)
  ret <- list()  # for the output
  ret$comment <- x[1]  # store the comment and discard from x
  x <- x[-1]
  
  # logical vector of where the pop specifiers are
  poplines <- str_detect(toupper(x), "^POP")
  
  # logical of where commas are:
  commalines <- str_detect(x, ",")
  
  # find the locus lines.  They all have a single word in them
  # and they don't have a comma and the aren't a pop line
  loclines <- sapply(strsplit(x, "\t"), length) == 1  & !poplines & !commalines 
  
  # here are the headers for the loci, essentially
  locus_names <- rep(x[loclines], each = 2)
  
  
  # now we need to get the alleles for everyone
  inds <- x[commalines]
  inds <- str_replace_all(inds, ",", "")
  indslist <- strsplit(inds, "\t")
  
  inds_for_output <- sapply(indslist, function(x) {
    ID <- x[1]
    a <- x[-1]
    tmp <- paste(as.numeric(str_sub(a, 1, NUM)), "\t", as.numeric(str_sub(a, NUM+1, 2 * NUM)), sep="")
    tmp2 <- c(ID, tmp)
    paste(tmp2, collapse = "\t")
  })
  
  
  # now output everything to a file
  header_line <- paste(c("",locus_names), collapse = "\t")
  
  cat(c(header_line, inds_for_output), sep = "\n", file = outfile)
  
  ret$comment
}
```

So, go ahead and copy that function, source it in R, and then do something like this:

```r
gpop2twocol("MyFile.txt")
```