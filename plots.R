library(ggplot2)
library(dplyr)

DF_ALL = readr::read_csv("outputs/DF_ALL.csv") # Leemos archivo

plot_jornada = 
  DF_ALL %>% 
  drop_na() %>% 
  group_by(jornada) %>% 
  summarise(num_vacantes = sum(num_vacantes)) %>% 
  ggplot(aes(jornada, num_vacantes, fill = jornada)) +
  geom_col(position = "stack") +
  theme_minimal() +
  theme(legend.position = "none") +
  labs(title = "Vacantes en centros privados concertados",
       subtitle = "Por tipo de jornada",
       y = "Número de vacantes", 
       caption = "@gorkang\nFuente: https://www.gobiernodecanarias.org/educacion/web/centros/gestion_centros/centros_privados_concertados/vacantes/")


plot_vacantes = 
  DF_ALL %>% 
  group_by(colegio) %>% 
  summarise(num_vacantes = sum(num_vacantes)) %>%  
  ggplot(aes(num_vacantes)) +
  geom_histogram() +
  scale_x_continuous(n.breaks = 20) +
  theme_minimal() +
  labs(title = "Vacantes en centros privados concertados",
       subtitle = "Número de vacantes ofertadas por centro",
       x = "Número de vacantes", 
       y = "Número de centros", 
       caption = "@gorkang\nFuente: https://www.gobiernodecanarias.org/educacion/web/centros/gestion_centros/centros_privados_concertados/vacantes/")


# Save plots --------------------------------------------------------------
ggsave("outputs/plots/jornada.png", plot_jornada, height = 9, width = 14, bg = "white")
ggsave("outputs/plots/vacantes.png", plot_vacantes, height = 9, width = 14, bg = "white")

