intl_input_parser <- function(.input_path){
        source_data_header <- readr::read_delim(.input_path, delim = " ", col_names = FALSE, n_max = 1)
        source_data <- list()

        source_data$params <- source_data_header %>%
                select(
                        simulation_duration = `X1`
                        , intersection_count = `X2`
                        , street_count = `X3`
                        , car_count = `X4`
                        , score_for_completion = `X5`
                ) %>%
                mutate(across(everything(), as.integer))

        source_data_streets <- readr::read_delim(.input_path, delim = " ", col_names = FALSE, skip = 1, n_max = source_data$params$street_count)

        source_data$streets <- source_data_streets %>%
                select(
                        starting_intersection = `X1`
                        , ending_intersection = `X2`
                        , street_name = `X3`
                        , travel_time = `X4`
                ) %>%
                mutate(across(c(starting_intersection, ending_intersection, travel_time), as.integer))


        source_data_paths <- read.delim(.input_path, sep = " ", header = FALSE, skip = 1 + source_data$params$street_count) %>% as_tibble()

        source_data$paths <- source_data_paths %>%
                rename(
                        roads_covered_count = `V1`
                ) %>%
                mutate(
                        car_id = row_number()
                ) %>%
                pivot_longer(
                        cols = starts_with("V")
                        , values_drop_na = T
                        , names_to = "road_number"
                        , values_to = "road_name"
                ) %>%
                mutate(
                        road_number = as.integer(str_replace(road_number, "V", "" ))
                ) %>%
                filter(road_name != '') %>%
                group_by(car_id, roads_covered_count) %>%
                nest() %>%
                ungroup() %>%
                rename(roads_covered = data)

        source_data
}
