
library(tidyverse)
library(stringr)


#' process a bibtex author list into something like EC Anderson, TC Ng, etc.
#' 
#' @param au a vector of bibtex author fields (to be used in a mutate)
#' 
#' 
bibnames2string <- function(au) {
  step1 <- str_split(au, " and ") %>%
    lapply(., function(x) {
      str_split(x, ",") %>%
        lapply(., function(y) {
          person <- str_trim(y, side = "both")
          person[2] <- str_replace_all(person[2], "[a-z. ]", "")
          paste(person[2], person[1])})
          }) 
    
    
   lapply(step1, function(x) paste("\"", unlist(x), "\"", sep = "", collapse = ", ")) %>%
     unlist()
}


#' convert a .bib file of publications to a tidy data frame
#' 
#' Just trying to get things into a form that I can pump into Hugo
#' Academic theme.
#' 
#' Note that this assumes every field is on a sinble line in the bib file.
#' @param B the path to the .bib file
bib2tidy <- function(B = "data/eric_website_citations.bib") {
 
  # here are the fields (in lower case) to keep
  keepers <- c(
    "author",
    "title",
    "journal",
    "year",
    "volume",
    "pages",
    "doi",
    "dryad",
    "github",
    "abstract",
    "url",
    "pubdate",
    "image",
    "image_preview",
    "selected"
  )
  
  b <- tibble(line = read_lines(B))
  
  tmp <- b %>%
    mutate(doctype = str_match(line, pattern = "@([:alpha:]+)\\{(.+),")[,2],
           citetag = str_match(line, pattern = "@([:alpha:]+)\\{(.+),")[,3]) %>%
    fill(doctype, citetag) %>%
    filter(!str_detect(line, "^@")) %>%
    filter(!is.na(doctype) & str_detect(line, "=")) %>%
    mutate(field = str_to_lower(str_trim(str_match(line, "^[:blank:]*([[:alnum:]-_]*) *=(.*)$")[,2], side = "both")),
           value = str_trim(str_match(line, "^[:blank:]*([[:alnum:]-_]*) *=(.*)$")[,3], side = "both")) %>%
    mutate(value = str_replace_all(value, "^\\{|\\}*,*$", "")) %>%
    filter(field %in% keepers) %>%
    select(-line) %>%
    spread(key = field, value = value)
  
  tmp2 <- tmp %>%
    mutate(author_string = bibnames2string(author)) %>%
    mutate(citetag_string = str_replace_all(citetag, "[^[:alnum:]]", ""),
           pub_string = str_c("In: _", journal, "_ **", volume, "**:", pages, "."),
           pub_type = ifelse(doctype == "article", 2, 0),
           title_string = str_c(title, ". (", year, ")"),
           doi_string = ifelse(is.na(doi), NA, str_c("\n\n[[url_custom]]\nname = \"doi-link\"\nurl = \"https://doi.org/", doi, "\"\n\n")),
           dryad_string = ifelse(is.na(dryad), NA, str_c("\n\n[[url_custom]]\nname = \"dryad\"\nurl = \"https://doi.org/", dryad, "\"\n\n")),
           github_string = ifelse(is.na(github), NA, str_c("\n\n[[url_custom]]\nname = \"github\"\nurl = \"", github, "\"\n\n"))
           )   
  
  tmp2
  
}


#' backslash escape backslashes
bs_escape <- function(s) {
  str_replace(s, "\\\\", "\\\\")
}

#' write a row of a tidy table to a file for Academic Hugo publication
#' 
#' @param D the data frame with the info
#' @param dir the directory to write the file to. 
#' 
write_hugo_pubs <- function(D, dir = "content/publication") {
  
  if(nrow(D) != 1) stop("Gotta have just one row in D")
  
  # this vector just shows how we map our columns to the fields wanted by Hugo Academic
  m <- c(
    abstract = "abstract",
    authors = "author_string",
    date = "pubdate",
    image = "image",
    image_preview = "image_preview",
    publication = "pub_string",
    publication_type = "pub_type",
    title = "title_string",
    url_code = "url_code",
    url_dataset = "url_dataset",
    url_pdf = "url_pdf",
    url_project = "url_project",
    url_slides = "url_slides",
    url_video = "url_video"
  )
  
  outf <- file.path(dir, str_c(D$citetag_string, ".md"))
  
  cat("+++\n", file = outf)
  dump <- lapply(names(m), function(n) {
    if (is.null(D[[m[n]]])) {
      s <- ""
    } else if(is.na(D[[m[n]]])) {
      s <- ""
    } else {
      s <- bs_escape(D[[m[n]]])
    }

    if(n == "authors") {
      out_str <- str_c(n, " = ", "[", s, "]")
    } else {
      out_str <- str_c(n, " = ", "\"", s, "\"")
    }
    cat(out_str, eol = "\n", file = outf, append = TRUE)
  })
  
  if(!is.na(D$selected)) {
    cat("selected = true\n", file = outf, append = TRUE)
  }
  if(!is.na(D$doi_string)) {
    cat(D$doi_string, file = outf, append = TRUE)
  }
  if(!is.na(D$github_string)) {
    cat(D$github_string, file = outf, append = TRUE)
  }
  if(!is.na(D$dryad_string)) {
    cat(D$dryad_string, file = outf, append = TRUE)
  }
  
  # need to put selected = true if appropriate
  
  
  cat("+++\n", file = outf, append = TRUE)
  
}


articles <- bib2tidy() %>%
  filter(doctype == "article")


for (i in 1:nrow(articles)) {
  write_hugo_pubs(articles[i, ])
}

