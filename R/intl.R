intl_input_parser_legacy <- function(.input_path){
        source_data_header <- readr::read_delim(.input_path, delim = " ", col_names = FALSE, n_max = 1) |> suppressWarnings()
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

        source_data_streets <- readr::read_delim(.input_path, delim = " ", col_names = FALSE, skip = 1, n_max = source_data$params$street_count) |> suppressWarnings()

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


intl_input_parser <- function(.input_path){
        source_data_header <- readr::read_delim(.input_path, delim = " ", col_names = FALSE, n_max = 1)
        source_data <- list()

        source_data$params <- source_data_header %>%
                select(
                        contributor_count = `X1`
                        , project_count = `X2`
                ) %>%
                mutate(across(everything(), as.integer))

        source_data_people <- list()
        read_start <- 1
        read_max <- 1

        for (i in 1:(source_data$params$contributor_count)) {
                current_contributor_params <- readr::read_delim(.input_path, delim = " ", col_names = FALSE, skip = read_start,  n_max = read_max) %>%
                        rename(name = `X1`, skill_count = `X2`) %>%
                        mutate(skill_count = as.integer(skill_count))
                read_start <- read_start + 1
                read_max <- current_contributor_params$skill_count
                current_contributor_skills <- readr::read_delim(.input_path, delim = " ", col_names = FALSE, skip = read_start, n_max = read_max) %>%
                        rename(
                                skill_name = `X1`
                                , skill_level = `X2`
                        ) %>%
                        mutate(name = current_contributor_params$name)
                current_contributor <-
                        current_contributor_params %>%
                        left_join(current_contributor_skills, by = "name") %>%
                        group_by(name, skill_count) %>%
                        nest() %>%
                        ungroup() %>%
                        rename(skills = data)

                source_data_people[[current_contributor$name]] <- current_contributor
                read_start <- read_start + current_contributor_params$skill_count
                read_max <- 1


        }

        source_data_projects <- list()
        read_max <- 1

        for (i in 1:(source_data$params$project_count)) {
                current_project_params <- readr::read_delim(.input_path, delim = " ", col_names = FALSE, skip = read_start,  n_max = read_max) %>%
                        rename(
                                name = `X1`
                                , days_to_complete = `X2`
                                , score_awarded = `X3`
                                , best_before_day = `X4`
                                , roles_count = `X5`
                                )
                read_start <- read_start + 1
                read_max <- current_project_params$roles_count
                current_project_skills <- readr::read_delim(.input_path, delim = " ", col_names = FALSE, skip = read_start,  n_max = read_max) %>%
                        rename(
                                skill_needed = `X1`
                                , level_needed = `X2`
                        ) %>%
                        mutate(name = current_project_params$name)
                current_project <-
                        current_project_params %>%
                        left_join(current_project_skills, by = "name") %>%
                        group_by(name, days_to_complete, score_awarded, best_before_day, roles_count) %>%
                        nest() %>%
                        ungroup() %>%
                        rename(roles = data)

                source_data_projects[[current_project$name]] <- current_project
                read_start <- read_start + current_project_params$roles_count
                read_max <- 1


        }

        source_data$people <- source_data_people
        source_data$projects <- source_data_projects


        source_data
}
