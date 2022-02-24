## code to prepare `DATASET` dataset goes here
library(dplyr)
library(readr)
library(tidyr)
library(stringr)

source("R/intl.R")

unzip("inst/extdata/qualification_round_2021.in.zip", exdir = "inst/extdata/qualification_round_2021")
legacy_part_a <- "inst/extdata/qualification_round_2021/a.txt" %>%
        intl_input_parser()

legacy_part_b <- "inst/extdata/qualification_round_2021/b.txt" %>%
        intl_input_parser()

legacy_part_c <- "inst/extdata/qualification_round_2021/c.txt" %>%
        intl_input_parser()

legacy_part_d <- "inst/extdata/qualification_round_2021/d.txt" %>%
        intl_input_parser()

legacy_part_e <- "inst/extdata/qualification_round_2021/e.txt" %>%
        intl_input_parser()

legacy_part_f <- "inst/extdata/qualification_round_2021/f.txt" %>%
        intl_input_parser()

usethis::use_data(legacy_part_a, overwrite = TRUE)
usethis::use_data(legacy_part_b, overwrite = TRUE)
usethis::use_data(legacy_part_c, overwrite = TRUE)
usethis::use_data(legacy_part_d, overwrite = TRUE)
usethis::use_data(legacy_part_e, overwrite = TRUE)
usethis::use_data(legacy_part_f, overwrite = TRUE)
