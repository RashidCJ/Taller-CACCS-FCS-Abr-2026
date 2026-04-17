# ============================================================================
# Taller Introducción a R — CACCS, Facultad de Ciencias Sociales, UPR-RP
# viernes 17 de abril de 2026, 10:00 a.m. – 12:00 p.m. (REB-120)
# Recurso: Dr. Rashid C.J. Marcano Rivera
#
# Script acompañante del documento Quarto: mismos chunks, sin la prosa.
# Para abrir el .qmd y ejecutar pieza por pieza, usen:
#   taller_intro_R_2026-04-17.qmd
#
# BASE BIBLIOGRÁFICA:
#   La introducción a R y RStudio (instalación, paneles, calculadora,
#   asignación, vectores, funciones, tipos de datos, conceptos básicos
#   de programación) sigue los capítulos 1–3 del libro de
#   Rafael A. Irizarry, "Introducción a la ciencia de datos" (Harvard,
#   edición en español, gratuito): https://rafalab.dfci.harvard.edu/dslibro/
#   Los casos sustantivos (Chile 1988, Cervantes/Galdós) y la
#   adaptación pedagógica a CSyH son contribución del autor.
#
# IMPORTANTE — Encoding UTF-8:
#   Este script usa nombres de objetos en español con tildes y eñes
#   (año_referéndum, educación). Para que R los lea correctamente,
#   RStudio debe guardar y leer en UTF-8:
#     Tools → Global Options → Code → Saving → Default text encoding: UTF-8
#   Si abren el archivo y ven símbolos raros (â€, Ã±), recárguenlo con:
#     File → Reopen with Encoding → UTF-8
# ============================================================================

set.seed(2026)
options(dplyr.summarise.inform = FALSE)


# ---------------------------------------------------------------------------
# Bloque 1 — RStudio + R como calculadora
# ---------------------------------------------------------------------------

# R como calculadora
1 + 2
13 / 2
2 ^ 6
sqrt(81)

# Asignar valores a objetos
pais <- "Chile"
pais

año_referéndum <- 1988
años_desde <- 2026 - año_referéndum
años_desde

es_caso_estudio <- TRUE
es_caso_estudio

# Vectores y funciones básicas
edades_demo <- c(23, 31, 27, 45, 38, 22, 29)
edades_demo
mean(edades_demo)
range(edades_demo)
length(edades_demo)


# ---------------------------------------------------------------------------
# Bloque 2 — Importar y explorar datos
# ---------------------------------------------------------------------------

library(tidyverse)
library(carData)

# Cargar el dataset incluido en el paquete
data(Chile)
chile <- as_tibble(Chile)
chile

# El mismo dataset desde un CSV externo
chile_csv <- read_csv("datos/chile.csv")
chile_csv

# Explorar
glimpse(chile)
summary(chile)
names(chile)
head(chile, 5)

# Otros formatos (no se ejecuta — solo referencia)
if (FALSE) {
  library(haven)
  datos_spss  <- read_sav("archivo.sav")
  datos_stata <- read_dta("archivo.dta")

  library(readxl)
  datos_xlsx  <- read_excel("archivo.xlsx")
}


# ---------------------------------------------------------------------------
# Bloque 3 — Tidyverse: cinco verbos
# ---------------------------------------------------------------------------

# Filtrar y seleccionar
chile |>
  filter(region == "M", sex == "F", vote == "Y") |>
  select(age, education, income, statusquo) |>
  head(10)

# Pipe |>
chile |>
  filter(vote == "Y") |>
  summarise(apoyo_medio = mean(statusquo, na.rm = TRUE),
            n = n())

# Mutate: recodificar y crear grupo etario
chile_anotado <- chile |>
  mutate(
    educación = recode(education,
                          "P"  = "Primaria",
                          "S"  = "Secundaria",
                          "PS" = "Post-secundaria"),
    grupo_etario = case_when(
      age < 30 ~ "18–29",
      age < 50 ~ "30–49",
      TRUE     ~ "50+"
    )
  )

chile_anotado |>
  select(age, grupo_etario, education, educación, vote) |>
  head(6)

# group_by + summarise
chile |>
  filter(!is.na(vote), !is.na(statusquo)) |>
  group_by(vote) |>
  summarise(
    n            = n(),
    apoyo_medio  = mean(statusquo),
    apoyo_de     = sd(statusquo)
  ) |>
  arrange(desc(apoyo_medio))

# Cruce educación × voto
chile_anotado |>
  filter(!is.na(vote), !is.na(educación)) |>
  count(educación, vote) |>
  group_by(educación) |>
  mutate(porcentaje = round(100 * n / sum(n), 1)) |>
  arrange(educación, vote)


# ---------------------------------------------------------------------------
# Bloque 4 — Visualización con ggplot2
# ---------------------------------------------------------------------------

# Distribución de statusquo por intención de voto
chile |>
  filter(!is.na(vote), !is.na(statusquo)) |>
  ggplot(aes(x = vote, y = statusquo, fill = vote)) +
  geom_violin(alpha = 0.6, trim = FALSE) +
  geom_boxplot(width = 0.15, alpha = 0.85, outlier.size = 0.7) +
  scale_fill_manual(values = c("A" = "#babcbe", "N" = "#1f77b4",
                               "U" = "#9467bd", "Y" = "#e70033")) +
  labs(
    title = "Apoyo al status quo según intención de voto (Chile, 1988)",
    subtitle = "A = abstención · N = No · U = indeciso · Y = Sí",
    x = "Intención de voto",
    y = "Apoyo al status quo (estandarizado)",
    fill = NULL
  ) +
  theme_minimal()

# Apoyo por edad y educación
chile_anotado |>
  filter(!is.na(statusquo), !is.na(educación)) |>
  ggplot(aes(x = age, y = statusquo, colour = educación)) +
  geom_point(alpha = 0.25, size = 1) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 1.1) +
  facet_wrap(~ educación) +
  scale_colour_manual(values = c("Primaria" = "#e70033",
                                 "Secundaria" = "#1f77b4",
                                 "Post-secundaria" = "#2ca02c")) +
  labs(
    title = "Apoyo al status quo por edad y educación (Chile, 1988)",
    x = "Edad (años)",
    y = "Apoyo al status quo",
    colour = "Educación"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# Composición del voto por región
chile |>
  filter(!is.na(vote)) |>
  count(region, vote) |>
  group_by(region) |>
  mutate(prop = n / sum(n)) |>
  ggplot(aes(x = region, y = prop, fill = vote)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_manual(values = c("A" = "#babcbe", "N" = "#1f77b4",
                               "U" = "#9467bd", "Y" = "#e70033")) +
  labs(
    title = "Composición del voto por región (Chile, 1988)",
    x = "Región",
    y = "Porcentaje",
    fill = "Voto"
  ) +
  theme_minimal()


# ---------------------------------------------------------------------------
# Bloque 5 — Modelo lineal: ¿quién apoyaba el régimen?
# ---------------------------------------------------------------------------

modelo <- lm(statusquo ~ income + age + sex + education,
             data = chile)
summary(modelo)

# Tabla limpia con broom
library(broom)
tidy(modelo, conf.int = TRUE) |>
  mutate(across(where(is.numeric), \(x) round(x, 4)))

# Forest plot de coeficientes
tidy(modelo, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  ggplot(aes(x = estimate, y = reorder(term, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high),
                  colour = "#e70033", linewidth = 0.8) +
  labs(
    title = "¿Qué predice el apoyo al status quo? (Chile, 1988)",
    x = "Coeficiente (efecto sobre apoyo al status quo)",
    y = NULL
  ) +
  theme_minimal()


# Ampliación opcional: regresión logística sobre el voto (no se ejecuta)
# Para audiencia de SOCI 4186, esto se trabaja en clase la próxima semana.
if (FALSE) {
  # Logística binaria: 1 = Sí a Pinochet, 0 = lo demás
  chile_glm <- chile |>
    mutate(voto_si = ifelse(vote == "Y", 1L, 0L))

  m_logit <- glm(voto_si ~ age + sex + education + income + statusquo,
                 data = chile_glm, family = binomial)
  summary(m_logit)

  library(emmeans)
  emmeans(m_logit, ~ education, type = "response")

  # Multinomial sobre las cuatro categorías originales
  library(nnet)
  chile_multi <- chile |>
    mutate(vote_multi = factor(vote,
                               levels = c("N", "Y", "A", "U"),
                               labels = c("No", "Sí", "Abstención", "Indeciso")))

  m_multi <- multinom(vote_multi ~ age + sex + education + income + statusquo,
                      data = chile_multi)
  summary(m_multi)
}


# ---------------------------------------------------------------------------
# Bloque 6 — Comparación de dos corpus: Cervantes vs. Galdós
# ---------------------------------------------------------------------------

library(gutenbergr)
library(tidytext)
library(stopwords)

# Cargar las dos obras (con respaldo local)
cargar_obra <- function(id, ruta_local) {
  if (file.exists(ruta_local)) {
    readRDS(ruta_local)
  } else {
    obra <- gutenberg_download(id)
    saveRDS(obra, ruta_local)
    obra
  }
}

quijote   <- cargar_obra(2000,  "datos/quijote.rds")     # Cervantes, 1605
fortunata <- cargar_obra(17013, "datos/fortunata.rds")   # Galdós, 1887

c(quijote   = nrow(quijote),
  fortunata = nrow(fortunata))

# Construir corpus etiquetado y tokenizar
corpus <- bind_rows(
  quijote   |> mutate(obra = "Quijote (Cervantes, 1605)"),
  fortunata |> mutate(obra = "Fortunata (Galdós, 1887)")
)

palabras <- corpus |>
  unnest_tokens(palabra, text)

palabras |>
  count(obra, name = "tokens")

# Frecuencias relativas tras quitar stopwords
vacias_es <- tibble(palabra = stopwords("es", source = "stopwords-iso"))

frecuencias <- palabras |>
  anti_join(vacias_es, by = "palabra") |>
  filter(nchar(palabra) > 2,
         !grepl("[0-9]", palabra)) |>
  count(obra, palabra, name = "n") |>
  group_by(obra) |>
  mutate(frec = n / sum(n)) |>
  ungroup()

frecuencias |>
  group_by(obra) |>
  slice_max(n, n = 10, with_ties = FALSE) |>
  arrange(obra, desc(n))

# Palabras distintivas (log-ratio)
distintivas <- frecuencias |>
  select(obra, palabra, frec) |>
  pivot_wider(names_from = obra, values_from = frec, values_fill = 0) |>
  rename(frec_quijote   = `Quijote (Cervantes, 1605)`,
         frec_fortunata = `Fortunata (Galdós, 1887)`) |>
  mutate(
    total = frec_quijote + frec_fortunata,
    log_ratio = log2((frec_quijote + 1e-6) / (frec_fortunata + 1e-6))
  ) |>
  filter(total > 0.0005)

top_quijote   <- distintivas |> slice_max(log_ratio, n = 10)
top_fortunata <- distintivas |> slice_min(log_ratio, n = 10)

bind_rows(
  top_quijote   |> mutate(lado = "Quijote"),
  top_fortunata |> mutate(lado = "Fortunata")
) |>
  select(lado, palabra, frec_quijote, frec_fortunata, log_ratio)

# Visualizar las palabras distintivas
bind_rows(
  top_quijote   |> mutate(lado = "Quijote (Cervantes, 1605)"),
  top_fortunata |> mutate(lado = "Fortunata (Galdós, 1887)")
) |>
  ggplot(aes(x = log_ratio,
             y = reorder(palabra, log_ratio),
             fill = lado)) +
  geom_col() +
  scale_fill_manual(values = c("Quijote (Cervantes, 1605)" = "#e70033",
                               "Fortunata (Galdós, 1887)"  = "#1f4e79")) +
  labs(
    title = "Vocabulario distintivo: Cervantes (1605) vs. Galdós (1887)",
    subtitle = "log2 de la razón de frecuencias relativas",
    x = "log2(frec Quijote / frec Fortunata)",
    y = NULL,
    fill = NULL
  ) +
  theme_minimal()

# Búsqueda de más obras en español (no se ejecuta — solo referencia)
if (FALSE) {
  obras_es <- gutenberg_works(languages = "es")
  obras_es |>
    filter(grepl("Baroja|Pardo Bazán|Unamuno|Hostos",
                 author, ignore.case = TRUE)) |>
    select(gutenberg_id, title, author)
}
