# ADVERTENCIA: Si corres las funciones de abajo, se instalarán los paquetes 
# necesarios si no los tuvieras instalados


# 0) Carga todas las funciones
invisible(lapply(list.files("./R", full.names = TRUE, pattern = ".R"), source))

# 1) Descargar los pdf's
download_all(WEB = "https://www.gobiernodecanarias.org/educacion/web/centros/gestion_centros/centros_privados_concertados/vacantes/")

# 2) Crear tabla con los pdf's y descarga a carpeta outputs/
create_table(folder_PDFs = "data/")


# 3) Ver Tabla (usando el paquete DT)
DF_ALL = readr::read_csv("outputs/DF_ALL.csv") # Leemos archivo
DT::datatable(DF_ALL) # Vemos tabla
