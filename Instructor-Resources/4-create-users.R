library(tidyverse)

marvel <- read_csv("Instructor-Resources/marvel-wikia-data.csv")
students <- read_csv("Instructor-Resources/Registrations_MRS_SVMT_03082017_registrants.csv")

create_creds <- function() {
  
  library(stringr)
  library(tidyverse)
  
  chars <- marvel %>% 
    slice(1:nrow(students)) %>% 
    select(name)
  
  chars <- chars %>% 
    mutate(char_name = substr(name, 1, str_locate(name, "\\(") - 2), 
           character = str_replace_all(str_to_lower(char_name), " ", "-")) %>% 
    select(-char_name, -name)
  
  names(students) <- str_to_lower(str_replace_all(names(students), " ", "_"))
  
  creds <- bind_cols(chars, students %>% select(first_name, last_name))
  
  return(creds)
  
}