create_table <- function(folder_PDFs = "data/") {
  
  if (!require('readr')) install.packages('readr'); library('readr')
  if (!require('dplyr')) install.packages('dplyr'); library('dplyr')
  if (!require('purrr')) install.packages('purrr'); library('purrr')
  if (!require('rvest')) install.packages('rvest'); library('rvest')
  if (!require('cli')) install.packages('cli'); library('cli')
  if (!require('tidyr')) install.packages('tidyr'); library('tidyr')
  library(tabulizer)
  
  FILES = list.files(folder_PDFs, full.names = TRUE)
  # FILES = "/home/emrys/gorkang@gmail.com/RESEARCH/PROYECTOS-Code/vacantes_concertados/data/180722_vacantes_cc_2.pdf"
  DF_ALL = 
    1:length(FILES) %>%
    map_df(~{
      # .x = 1
      cli::cli_alert("{.x}: {basename(FILES[.x])}")
      TEXT = tabulizer::extract_text(FILES[.x])
      out1 <- extract_tables(FILES[.x], method = "decide")
      
      NAME = gsub(".*\\n[0-9]{8} (.*?)\\n.*", "\\1", TEXT)
      FECHA = gsub(".*Fecha de publicación: (.*?)\\n[0-9]{8}.*", "\\1", TEXT)
      TABLE_RAW = out1[[1]] %>% as_tibble() %>% janitor::row_to_names(row_number = 1) %>% janitor::clean_names() %>% 
        mutate(colegio = NAME,
               file = basename(FILES[.x]),
               fecha = FECHA)
        
      if (ncol(TABLE_RAW) == 6 & !"x" %in% names(TABLE_RAW)) {
        
        DF = TABLE_RAW
        
      } else if (ncol(TABLE_RAW) == 6 & "x" %in% names(TABLE_RAW)) {
        cli::cli_alert_warning("{.x}: {names(TABLE_RAW)}")
        DF = TABLE_RAW %>% 
          rename(especialidad = x,
                 jornada = especialidad_jornada)
        
      } else if (ncol(TABLE_RAW) == 5) {
        
        PARCIAL = grepl("PARCIAL", TABLE_RAW$especialidad_jornada)
        COMPLETA = grepl("COMPLETA", TABLE_RAW$especialidad_jornada)
        
        jornada_DF = tibble(PARCIAL, COMPLETA) %>% 
          mutate(jornada_str = 
                   case_when(
                     PARCIAL == TRUE ~ "PARCIAL",
                     COMPLETA == TRUE ~ "COMPLETA",
                     TRUE ~ ""))
  
        
        DF = TABLE_RAW %>% separate(especialidad_jornada, into = c("especialidad", "jornada"),
                               sep = " PARCIAL| COMPLETA") %>% 
          mutate(jornada = jornada_DF$jornada_str) 
        
      } else {
        cli::cli_alert_warning("{.x}: {names(TABLE_RAW)}")
        DF = TABLE_RAW %>% 
          mutate(especialidad = x)
      }
      
      
    DF %>% 
      # Eliminamos filas que no son plazas
      filter(!grepl("[a-z]{3,10}", especialidad, ignore.case = FALSE)) %>% 
      filter(!grepl("@", especialidad)) %>% 
      filter(!grepl("curriculum|currículum", especialidad)) %>% 
      filter(!grepl("sustitución", especialidad)) %>% 
      filter(!grepl("solicitud", especialidad)) %>%
      filter(!grepl("enviar", especialidad)) %>%
      
      # Tratamos de recuperar la informacion cuando hay varias lineas para las mismas vacantes
      mutate(especialidad = 
               case_when(
                 lead(num_vacantes) == "" & num_vacantes == "1" ~ paste(especialidad, lead(especialidad)),
                 TRUE ~ especialidad
               ),
             jornada = 
               case_when(
                 lead(num_vacantes) == "" & num_vacantes == "1" & jornada == "" ~ lead(jornada),
                 lead(num_vacantes) == "" & num_vacantes == "1" & jornada != "" ~ jornada,
                 grepl("PARCIAL", especialidad, ignore.case = FALSE) & jornada == "" ~ "PARCIAL",
                 grepl("COMPLETA", especialidad, ignore.case = FALSE) & jornada == "" ~ "COMPLETA",
                 TRUE ~ jornada
               )) %>% 
      select(num_vacantes, especialidad, jornada, colegio, file, fecha) %>% 
      filter(num_vacantes != "")
    
    })
  
  if (!file.exists("outputs/")) dir.create("outputs/")
  
  write_csv(DF_ALL, "outputs/DF_ALL.csv")
  cli::cli_alert_success("ALL OK")
  

}
