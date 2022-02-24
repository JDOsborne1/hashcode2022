## code to prepare `DATASET` dataset goes here
library(dplyr)
library(readr)
library(tidyr)
library(stringr)

source("R/intl.R")

part_a <- "inst/extdata/qualification_round_2022/a_an_example.in.txt" %>%
        intl_input_parser()
part_b <- "inst/extdata/qualification_round_2022/b_better_start_small.in.txt" %>%
        intl_input_parser()
part_c <- "inst/extdata/qualification_round_2022/c_collaboration.in.txt" %>%
        intl_input_parser()
part_d <- "inst/extdata/qualification_round_2022/d_" %>%
        intl_input_parser()
part_e <- "inst/extdata/qualification_round_2022/e_exceptional_skills.in.txt" %>%
        intl_input_parser()
part_f <- "inst/extdata/qualification_round_2022/f_find_great_mentors.in.txt" %>%
        intl_input_parser()

usethis::use_data(part_a, overwrite = TRUE)
usethis::use_data(part_b, overwrite = TRUE)
usethis::use_data(part_c, overwrite = TRUE)
usethis::use_data(part_d, overwrite = TRUE)
usethis::use_data(part_e, overwrite = TRUE)
usethis::use_data(part_f, overwrite = TRUE)


source("R/matching.R")

part_c_solution <- part_c %>%
        project_manager()


usethis::use_data(part_c_solution, overwrite = TRUE)

