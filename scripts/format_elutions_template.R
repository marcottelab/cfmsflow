########
# This is a script to set up experiments for calculating features
# Can be further customized to modify eg. type of normalization or filters based on protein abundance
#     or to make elutions of specific sets of experiments


library(tidyverse)

# Functions
read_elut <- function(data_path, elut_files, delim){
  
    elut <- tibble(filename = elut_files) %>%
               mutate(file_contents = map(filename, ~ read_csv(delim = delim, file.path(data_path, .)))) %>%
               unnest(cols = c(file_contents))
    return(elut)
}

normalize_elut <- function(elut){
    # Normalize experiment by total observations of each protein in the experiment
    elut_norm <- elut %>% 
                      group_by(ID, ExperimentID) %>%
                      mutate(expnorm_value = value/max(value)) %>%
                      ungroup
                     
}

calc_totals <- function(elut){
    # Calculate total peptide counts for each protein across all experiments
    count_total <- elut %>%
                       #Calculate total number of spectral counts per protein across all experiments
                       group_by(ID) %>%
                           summarize(total_count = sum(value)) %>%
                       ungroup 
}

calc_totals_exp <- function(elut){
    # Calculate total peptide counts for each protein across all experiments
    count_exp <- elut %>%
      #Calculate total number of spectral counts per protein across all experiments
      group_by(ID, ExperimentID) %>%
      summarize(exp_count = sum(value)) %>%
      ungroup 
  }

#setup_filter <- function(count, threshold){
    # Choose IDs to keep based on some criteria 
#    ids_to_keep <- count %>%                    
#                       filter(n >= threshold) %>%
#                       select(ID) %>%
#                       unique
# }


write_elution_exp <- function(df){
    #Function to write a single experiment  
    outfile <- paste0(
       "elutions/processed_elutions/",  
        str_replace(df$filename[1], "elut.tidy", "singleexp_elut_expnormspeccounts.wide"), sep = "")

    df %>% select(FractionID, ID, expnorm_value) %>%
        spread(FractionID, expnorm_value, fill = 0 ) %>% 
        write_csv(outfile)

  
}


write_hypergeo_exp <- function(df){

    # Function to write each experiment formatted for calculating the hypergeometric feature 
    outfile <- paste0(
      "elutions/processed_elutions/min5_",  
      str_replace(df$filename[1], "elut.tidy", "elut_min5threshold.tidy"), sep = "")
    
    df %>% 
        select(ID, FractionID) %>%
        write_csv(outfile)
}


########################################
# Format of input elut.tidy files 


# ExperimentID,FractionID,ID,value
# hek_SEC,hek_SEC_fraction10,COX1_HUMAN,10.0

# arath_IEX2,arath_iex_2_fracion3,ENOG411ABC,5


# Location of input elut.tidy files

data_path <- "elutions/input_elutions"
elut_filenames <- dir(data_path, pattern = "*elut.tidy") # Get filenames

print("Located elution files")
print(elut_filenames)


print("Reading all elution files")

elut <- read_elut(data_path, elut_filenames, delim = ",")


#check names of columns
#######################################
# Processing steps, normalizing, filtering...

print("Normalizing elution files")
elut_norm <- normalize_elut(elut)
elut_norm %>% write_csv("elutions/processed_elutions/elut_norm.tidy")


print("Setting up abundance and species filter")
count_total <- calc_totals(elut)
count_exp <- calc_totals_exp(elut)
print("Making list of proteins to keep") 

print("Default filters:\n 10 * total number of experiments spectral counts\n At least 10 spectral counts per experiment")
print(paste("Removing proteins with fewer than", 10 * length(elut_filenames), " total identified PSMs across experiments"))
print(paste("Removing proteins with fewer than", 10 , " identified PSMs in an experiment"))

print("Filtering to only selected IDs from filter")

elut_filt <- elut_norm %>%
  left_join(count_total, by = "ID") %>%
  left_join(count_exp, by = c("ID", "ExperimentID")) %>%
  filter(exp_count >= 10) %>%
  filter(total_count >= 10 * length(elut_filenames)) %>%
  select(-total_count, -exp_count)

#elut_filt <- elut_norm %>% 
#                   filter(ID %in% ids_to_keep$ID)

elut_filt %>% write_csv("elutions/processed_elutions/elut_normfilt.tidy")


######################################
# Writing

print("Writing one output per experiment")

elut_filt %>% split(.$filename) %>% map(write_elution_exp)

print("Writing an elution of all experiments combined")

elut_filt %>%
  select(FractionID, ID, expnorm_value) %>%
  spread(FractionID, expnorm_value, fill = 0 ) %>%
  write_csv("elutions/processed_elutions/all_expconcat_elut_expnormspeccounts.wide")

print("Writing files formattted for hypergeometric features")

elut_filt_threshold <- elut_filt %>% filter(value >= 5)
elut_filt_threshold %>% split(.$filename) %>% map(write_hypergeo_exp)

elut_filt_threshold %>%
  select(ID, FractionID) %>%
  write_csv("elutions/processed_elutions/all_elut_min5threshold.tidy")

print("Complete")
