library(purrr)
library(dplyr)
library(tidyr)



project_manager <- function(.input){


        people <- .input$people %>%
                map(ungroup)

        base_ds <- people[[1]]
        for (i in 2:length(people)){
                base_ds <- rbind(base_ds, people[[i]])
        }
        parsed_people <-  base_ds %>%
                unnest(skills) %>%
                group_by(name) %>%
                mutate(
                        count_skills = n()
                        , total_skill_level = sum(skill_level)
                )

        projects <- .input$projects %>%
                map(ungroup)

        base_ds <- projects[[1]]
        for (i in 2:length(projects)){
                base_ds <- rbind(base_ds, projects[[i]])
        }
        parsed_projects <-  base_ds %>%
                unnest(roles)%>%
                group_by(name) %>%
                mutate(
                        count_skills_needed = n()
                        , total_skills_needed = sum(level_needed)
                        , in_project_skill_order = row_number()
                        ) %>%
                ungroup() %>%
                mutate(
                        points_per_day = score_awarded/days_to_complete
                        , points_per_role = score_awarded/count_skills_needed
                        , points_per_level = score_awarded/total_skills_needed
                        )


        joined_projects_and_people <-
                parsed_projects %>%
                inner_join(parsed_people, suffix = c('.project', '.people'), by = c('skill_needed' = 'skill_name'))

        scored_and_sorted <- joined_projects_and_people %>%
                mutate(skill_overshoot = skill_level - level_needed) %>%
                filter(skill_overshoot >= 0) %>%
                arrange(skill_overshoot)

        worked_projects <- NULL
        for (i in unique(scored_and_sorted$name.project)){
                base_df <- NULL
                eligible_workers <- scored_and_sorted %>%
                        filter(name.project == i) %>%
                        pull(name.people) %>%
                        unique()
                eligible_skills <- scored_and_sorted %>%
                        filter(name.project == i) %>%
                        pull(skill_needed) %>%
                        unique()
                for (j in 1:10){
                        assignment_round <- scored_and_sorted %>%
                                filter(name.project == i) %>%
                                filter(name.people %in% eligible_workers) %>%
                                filter(skill_needed %in% eligible_skills) %>%
                                group_by(name.project, skill_needed) %>%
                                summarise(assignee = first(name.people), .groups = "drop") %>%
                                ungroup() %>%
                                group_by(assignee) %>%
                                mutate(occurance = row_number()) %>%
                                ungroup() %>%
                                filter(occurance == 1)

                        base_df <- rbind(base_df, assignment_round)
                        eligible_workers <- base::setdiff( eligible_workers, assignment_round$assignee)
                        eligible_skills <- base::setdiff(eligible_skills, assignment_round$skill_needed)
                        if (length(eligible_workers) == 0){
                                break
                        }

                }

                worked_projects <- rbind(worked_projects, base_df)
        }

        chosen_workers <- scored_and_sorted %>%
                distinct(name.project, count_skills_needed) %>%
                left_join(worked_projects, by = c('name.project')) %>%
                group_by(name.project) %>%
                mutate(skills_assigned = n()) %>%
                ungroup() %>%
                filter(skills_assigned == count_skills_needed) %>%
                select(name.project, skill_needed, assignee)


        ordered_workers <- chosen_workers %>%
                inner_join(parsed_projects, c('name.project' = 'name', 'skill_needed')) %>%
                arrange(name.project, in_project_skill_order)

        projects_table <- ordered_workers %>%
                group_by(name.project) %>%
                summarise(assignees = glue_collapse(assignee, sep = ' ')) %>%
                mutate(project_assignment = glue('{name.project} \n {assignees}'))
        projects_list <- projects_table %>%
                pull(project_assignment)

        projects_count <- projects_table %>%
                nrow()

        glue('{projects_count}\n{glue_collapse(projects_list, sep = "\n")}')


}
