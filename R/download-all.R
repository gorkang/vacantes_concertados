download_all <- function(WEB = "https://www.gobiernodecanarias.org/educacion/web/centros/gestion_centros/centros_privados_concertados/vacantes/") {

  if (!require('dplyr')) install.packages('dplyr'); library('dplyr')
  if (!require('purrr')) install.packages('purrr'); library('purrr')
  if (!require('rvest')) install.packages('rvest'); library('rvest')
  if (!require('cli')) install.packages('cli'); library('cli')
  if (!require('tidyr')) install.packages('tidyr'); library('tidyr')
  
  # tabulizer requiere rJava:
  # Instalar tabulizer: remotes::install_github(c("ropensci/tabulizerjars", "ropensci/tabulizer"))
  # Para instalar rJava: https://stackoverflow.com/questions/3311940/r-rjava-package-install-failing
  library(tabulizer)
  
  page_source_rvest <- rvest::read_html(WEB)
  
  DF =
    page_source_rvest %>% html_elements("a") %>% html_attr("href") %>% tibble(href = .) %>% 
    filter(grepl("pdf", href)) %>% mutate(filename = basename(href)) %>% 
    distinct(filename, .keep_all = TRUE)
  
  if (!file.exists("data/")) dir.create("data/")
  
  cli::cli_alert_info("Se descargarán {nrow(DF)} pdf's en 'data/'")
  1:nrow(DF) %>%
    walk(~{
      # .x = 1
      wait_n = runif(1, min = 1, max = 10)
      
      cli::cli_alert_info("{.x}/{nrow(DF)}: {wait_n}")
      Sys.sleep(wait_n)
      URL_download = paste0("https://www.gobiernodecanarias.org/", DF$href[.x])
      download.file(URL_download, destfile = paste0("data/", DF$filename[.x]), mode = "wb")
    })

}
