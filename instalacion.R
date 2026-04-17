# ---------------------------------------------------------------------------
# Taller Introducción a R — CACCS, Facultad de Ciencias Sociales, UPRRP
# viernes 17 de abril de 2026, 10:00 a.m. – 12:00 p.m. (REB-120)
# Recurso: Dr. Rashid C.J. Marcano Rivera
#
# Script de instalación de paquetes.
# Corran este archivo UNA SOLA VEZ antes del taller, idealmente con conexión
# estable a internet. Si todos los paquetes ya están instalados, no hace nada.
# ---------------------------------------------------------------------------

paquetes <- c(
  # Núcleo
  "tidyverse",   # dplyr, ggplot2, tidyr, readr, stringr, etc.
  "scales",      # formato de ejes (porcentajes, monedas)

  # Datos del caso aplicado
  "carData",     # encuesta Chile 1988 y otros datasets clásicos

  # Modelado
  "broom",       # convertir modelos en tablas tidy
  "emmeans",     # medias marginales y probabilidades predichas (glm/multinom)
  "ggeffects",   # efectos marginales con intervalos de confianza para ggplot2

  # Importación y exportación opcional
  "haven",       # leer/escribir SPSS (.sav) y Stata (.dta)
  "readxl",      # leer Excel (.xlsx)
  "writexl",     # escribir Excel (.xlsx)

  # Análisis de texto en español
  "gutenbergr",  # Proyecto Gutenberg
  "tidytext",    # tokenización tidy
  "stopwords",   # stopwords en español

  # Render
  "ragg",        # dispositivo gráfico que maneja Unicode (en-dash, acentos)
  "rmarkdown"    # render fallback si no usan Quarto
)

nuevos <- setdiff(paquetes, rownames(installed.packages()))

if (length(nuevos) == 0) {
  message("Todos los paquetes ya están instalados.")
} else {
  message("Instalando: ", paste(nuevos, collapse = ", "))
  install.packages(nuevos, dependencies = TRUE)
}

# Verificación: imprimir estado de cada paquete
invisible(lapply(paquetes, function(p) {
  ok <- requireNamespace(p, quietly = TRUE)
  message(sprintf("  %-15s %s", p, if (ok) "OK" else "FALTA"))
}))

message("\nListo. Si todo dice OK, están listos para el taller.")
