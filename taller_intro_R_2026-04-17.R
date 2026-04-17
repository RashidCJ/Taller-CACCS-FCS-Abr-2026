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
#   Si abrieran el archivo y vieran símbolos raros (â€, Ã±), recárguenlo con:
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
# ?Chile — ejecutar en consola para abrir la documentación

# Reordenar education al orden lógico (P → S → PS) en vez del alfabético
# que sería P → PS → S. Se propaga a todas las gráficas y modelos.
chile <- as_tibble(Chile) |>
  mutate(education = factor(education, levels = c("P", "S", "PS")))
chile

# Exporta datos de Chile como chile.csv (solo si no existe — evita sobrescribir)
if (!file.exists("datos/chile.csv")) {
  write_csv(Chile, "datos/chile.csv")
}

# El mismo dataset desde un CSV externo
chile_csv <- read_csv("datos/chile.csv")
chile_csv

# Explorar
glimpse(chile)
summary(chile)
names(chile)
head(chile, 5)

# Otros formatos de importación (no se ejecuta — solo referencia)
if (FALSE) {
  library(haven)
  datos_spss  <- read_sav("archivo.sav")
  datos_stata <- read_dta("archivo.dta")

  library(readxl)
  datos_xlsx  <- read_excel("archivo.xlsx")
}

# Guardar y exportar (no se ejecuta — solo referencia)
# Regla práctica: CSV para intercambio universal, .rds para preservar
# objetos R con todos sus atributos, .sav/.dta para SPSS/Stata,
# .xlsx para audiencias administrativas.
if (FALSE) {
  # CSV (universal)
  write_csv(chile, "datos/chile_export.csv")

  # RDS (nativo de R — preserva tipos, factores, atributos)
  saveRDS(chile, "datos/chile.rds")
  chile_recuperado <- readRDS("datos/chile.rds")

  # SPSS y Stata (preservan etiquetas)
  library(haven)
  write_sav(chile, "datos/chile.sav")
  write_dta(chile, "datos/chile.dta")

  # Excel
  library(writexl)
  write_xlsx(chile, "datos/chile.xlsx")

  # Guardar un gráfico de ggplot2
  library(ggplot2)
  mi_grafico <- ggplot(chile, aes(x = age, y = statusquo)) + geom_point()
  ggsave("figuras/dispersion_chile.png", mi_grafico,
         width = 8, height = 5, dpi = 300)
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

# Mutate: recodificar y crear grupo etario.
# educación se define como factor ordenado para preservar el orden
# lógico Primaria → Secundaria → Post-secundaria en las gráficas.
chile_anotado <- chile |>
  mutate(
    educación = factor(
      recode(education,
             "P"  = "Primaria",
             "S"  = "Secundaria",
             "PS" = "Post-secundaria"),
      levels = c("Primaria", "Secundaria", "Post-secundaria")
    ),
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

# Forest plot de coeficientes (línea verde = cero, efecto nulo)
tidy(modelo, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  ggplot(aes(x = estimate, y = reorder(term, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed",
             colour = "#38B44A", linewidth = 0.8) +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high),
                  colour = "#e70033", linewidth = 0.8) +
  labs(
    title = "¿Qué predice el apoyo al status quo? (Chile, 1988)",
    subtitle = "Línea verde marca efecto nulo",
    x = "Coeficiente (efecto sobre apoyo al status quo)",
    y = NULL
  ) +
  theme_minimal()


# Efectos marginales con ggeffects
library(ggeffects)

# Efecto del ingreso (continuo)
pred_income <- ggpredict(modelo, terms = "income [all]")
ggplot(pred_income, aes(x = x, y = predicted)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high),
              fill = "#e70033", alpha = 0.20) +
  geom_line(colour = "#e70033", linewidth = 1) +
  labs(
    title = "Apoyo predicho al status quo según ingreso",
    subtitle = "Resto de variables en sus valores típicos",
    x = "Ingreso mensual (pesos chilenos, 1988)",
    y = "Apoyo al status quo (predicho)"
  ) +
  theme_minimal()

# Efecto de la edad por sexo
pred_age_sex <- ggpredict(modelo, terms = c("age [20:70]", "sex"))
ggplot(pred_age_sex, aes(x = x, y = predicted, colour = group, fill = group)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high),
              alpha = 0.15, colour = NA) +
  geom_line(linewidth = 1.1) +
  scale_colour_manual(values = c("F" = "#e70033", "M" = "#1f4e79"),
                      labels = c("F" = "Mujeres", "M" = "Hombres")) +
  scale_fill_manual(values = c("F" = "#e70033", "M" = "#1f4e79"),
                    labels = c("F" = "Mujeres", "M" = "Hombres")) +
  labs(
    title = "Apoyo predicho al status quo por edad y sexo",
    x = "Edad (años)",
    y = "Apoyo al status quo (predicho)",
    colour = "Sexo",
    fill = "Sexo"
  ) +
  theme_minimal()

# Efecto de la educación (categórica)
pred_edu <- ggpredict(modelo, terms = "education")
ggplot(pred_edu, aes(x = x, y = predicted)) +
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high),
                  colour = "#e70033", linewidth = 0.9, size = 0.8) +
  labs(
    title = "Apoyo predicho al status quo por nivel educativo",
    subtitle = "P = Primaria · S = Secundaria · PS = Post-secundaria",
    x = "Nivel educativo",
    y = "Apoyo al status quo (predicho)"
  ) +
  theme_minimal()


# ---------------------------------------------------------------------------
# Regresión logística sobre el voto (binaria)
# ---------------------------------------------------------------------------

# Binomización: solo quienes tomaron posición (Sí vs. No).
# Excluir A (abstención) y U (indeciso) — fundirlos con No mezcla
# oposición explícita con no-respuesta, distorsionando el modelo.
chile_glm <- chile |>
  filter(vote %in% c("Y", "N")) |>
  mutate(voto_si = as.integer(vote == "Y"))

chile_glm |> count(vote, voto_si) |> arrange(vote)

# Ajustar modelo
m_logit <- glm(voto_si ~ age + sex + education + income + statusquo,
               data = chile_glm, family = binomial)
summary(m_logit)

# Tabla con odds ratios (exponentiate = TRUE)
tidy(m_logit, conf.int = TRUE, exponentiate = TRUE) |>
  mutate(across(where(is.numeric), \(x) round(x, 3)))

# Coefplot con línea verde en el cero
tidy(m_logit, conf.int = TRUE) |>
  filter(term != "(Intercept)") |>
  ggplot(aes(x = estimate, y = reorder(term, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed",
             colour = "#38B44A", linewidth = 0.8) +
  geom_pointrange(aes(xmin = conf.low, xmax = conf.high),
                  colour = "#e70033", linewidth = 0.8) +
  labs(
    title = "Predictores del voto Sí (Chile, 1988)",
    subtitle = "Coeficientes en log-odds — línea verde = efecto nulo",
    x = "Coeficiente (log-odds)",
    y = NULL
  ) +
  theme_minimal()

# Efectos marginales: probabilidad predicha según statusquo
pred_sq <- ggpredict(m_logit, terms = "statusquo [all]")
ggplot(pred_sq, aes(x = x, y = predicted)) +
  geom_hline(yintercept = 0.5, linetype = "dashed",
             colour = "#38B44A", linewidth = 0.8) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high),
              fill = "#e70033", alpha = 0.20) +
  geom_line(colour = "#e70033", linewidth = 1) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, 1)) +
  labs(
    title = "Probabilidad predicha de voto Sí según statusquo",
    subtitle = "Línea verde en 50% = umbral de clasificación",
    x = "Actitud hacia el status quo",
    y = "Probabilidad de voto Sí"
  ) +
  theme_minimal()

# Efectos marginales por nivel educativo
pred_edu_glm <- ggpredict(m_logit, terms = "education")
ggplot(pred_edu_glm, aes(x = x, y = predicted)) +
  geom_hline(yintercept = 0.5, linetype = "dashed",
             colour = "#38B44A", linewidth = 0.8) +
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high),
                  colour = "#e70033", linewidth = 0.9, size = 0.8) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, 1)) +
  labs(
    title = "Probabilidad predicha de voto Sí por nivel educativo",
    subtitle = "P = Primaria · S = Secundaria · PS = Post-secundaria",
    x = "Nivel educativo",
    y = "Probabilidad de voto Sí"
  ) +
  theme_minimal()

# Efectos marginales por edad y sexo
pred_age_sex_glm <- ggpredict(m_logit, terms = c("age [20:70]", "sex"))
ggplot(pred_age_sex_glm, aes(x = x, y = predicted, colour = group, fill = group)) +
  geom_hline(yintercept = 0.5, linetype = "dashed",
             colour = "#38B44A", linewidth = 0.8) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high),
              alpha = 0.15, colour = NA) +
  geom_line(linewidth = 1.1) +
  scale_colour_manual(values = c("F" = "#e70033", "M" = "#1f4e79"),
                      labels = c("F" = "Mujeres", "M" = "Hombres")) +
  scale_fill_manual(values = c("F" = "#e70033", "M" = "#1f4e79"),
                    labels = c("F" = "Mujeres", "M" = "Hombres")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, 1)) +
  labs(
    title = "Probabilidad predicha de voto Sí por edad y sexo",
    x = "Edad (años)",
    y = "Probabilidad de voto Sí",
    colour = "Sexo",
    fill = "Sexo"
  ) +
  theme_minimal()


# ---------------------------------------------------------------------------
# Regresión multinomial: las cuatro categorías de voto
# ---------------------------------------------------------------------------

library(nnet)

chile_multi <- chile |>
  mutate(vote_multi = factor(vote,
                             levels = c("N", "Y", "A", "U"),
                             labels = c("No", "Sí", "Abstención", "Indeciso")))

m_multi <- multinom(vote_multi ~ age + sex + education + income + statusquo,
                    data = chile_multi, trace = FALSE)
summary(m_multi)

# Probabilidades predichas por statusquo
pred_multi_sq <- ggpredict(m_multi, terms = "statusquo [all]")

colores_voto <- c("No" = "#1f77b4",
                  "Sí" = "#e70033",
                  "Abstención" = "#babcbe",
                  "Indeciso" = "#9467bd")

ggplot(pred_multi_sq, aes(x = x, y = predicted, colour = response.level)) +
  geom_hline(yintercept = 0, linetype = "dashed",
             colour = "#38B44A", linewidth = 0.8) +
  geom_line(linewidth = 1.2) +
  scale_colour_manual(values = colores_voto) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0, 1)) +
  labs(
    title = "Probabilidad predicha de cada voto según statusquo",
    x = "Actitud hacia el status quo",
    y = "Probabilidad predicha",
    colour = "Voto"
  ) +
  theme_minimal()

# Composición predicha por educación
pred_multi_edu <- ggpredict(m_multi, terms = "education")
ggplot(pred_multi_edu, aes(x = x, y = predicted, fill = response.level)) +
  geom_col(position = "fill") +
  scale_fill_manual(values = colores_voto) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Composición predicha del voto por nivel educativo",
    subtitle = "P = Primaria · S = Secundaria · PS = Post-secundaria",
    x = "Nivel educativo",
    y = "Probabilidad predicha",
    fill = "Voto"
  ) +
  theme_minimal()


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
    # Normalizar encoding a UTF-8 (algunos textos del Proyecto Gutenberg
    # vienen en Latin1 y romperían las tildes al tokenizar).
    obra$text <- iconv(obra$text, from = "", to = "UTF-8", sub = "")
    saveRDS(obra, ruta_local)
    obra
  }
}

quijote   <- cargar_obra(2000,  "datos/quijote.rds")     # Cervantes, 1605
fortunata <- cargar_obra(17013, "datos/fortunata.rds")   # Galdós, 1887

c(quijote   = nrow(quijote),
  fortunata = nrow(fortunata))

# Nota técnica: algunos textos viejos del Proyecto Gutenberg vienen en
# Latin1/ISO-8859-1 en vez de UTF-8. Si los procesaran tal cual,
# tildes y eñes se romperían (ej. "también" → "tambi"). Normalización:
#   fortunata$text <- iconv(fortunata$text, from = "latin1", to = "UTF-8")
# Los .rds de este taller ya están normalizados.

# Construir corpus etiquetado y tokenizar
corpus <- bind_rows(
  quijote   |> mutate(obra = "Quijote (Cervantes, 1605)"),
  fortunata |> mutate(obra = "Fortunata (Galdós, 1887)")
)

palabras <- corpus |>
  unnest_tokens(palabra, text)

palabras |>
  count(obra, name = "tokens")

# Paso intermedio: frecuencias crudas SIN remover stopwords
# (sirve para mostrar por qué hay que limpiar — las top palabras
#  son siempre 'de', 'que', 'la', 'y' en cualquier texto en español)
palabras |>
  group_by(obra) |>
  count(palabra, sort = TRUE) |>
  slice_max(n, n = 5, with_ties = FALSE)

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
  geom_vline(xintercept = 0, linetype = "dashed",
             colour = "#38B44A", linewidth = 0.8) +
  scale_fill_manual(values = c("Quijote (Cervantes, 1605)" = "#e70033",
                               "Fortunata (Galdós, 1887)"  = "#1f4e79")) +
  labs(
    title = "Vocabulario distintivo: Cervantes (1605) vs. Galdós (1887)",
    subtitle = "log2 de la razón de frecuencias relativas — verde = frecuencia equivalente",
    x = "log2(frec Quijote / frec Fortunata)",
    y = NULL,
    fill = NULL
  ) +
  theme_minimal()


# ---------------------------------------------------------------------------
# Aplicación: discursos inaugurales presidenciales (no se ejecuta)
# Misma lógica de vocabulario distintivo, ahora con quanteda y
# textstat_keyness(). Para correrlo:
#   install.packages(c("quanteda", "quanteda.textstats", "quanteda.textplots"))
# ---------------------------------------------------------------------------
if (FALSE) {
  library(quanteda)
  library(quanteda.textstats)
  library(quanteda.textplots)

  # Corpus inaugural (incluido en quanteda)
  corp_inaug <- data_corpus_inaugural
  summary(corp_inaug, 5)

  # Tokenizar, limpiar, DFM
  toks_inaug <- tokens(corp_inaug,
                       remove_punct = TRUE,
                       remove_numbers = TRUE) |>
    tokens_tolower() |>
    tokens_remove(stopwords("en"))

  dfm_inaug <- dfm(toks_inaug)

  # Comparar Obama (2009) vs. Trump (2017)
  dfm_comp <- dfm_inaug |>
    dfm_subset(President %in% c("Obama", "Trump") &
                 Year %in% c(2009, 2017))

  k <- textstat_keyness(dfm_comp,
                        target = docvars(dfm_comp)$President == "Obama")

  textplot_keyness(k, n = 15) +
    labs(title = "Vocabulario distintivo: Obama (2009) vs. Trump (2017)")
}


# Búsqueda de más obras en español (no se ejecuta — solo referencia)
if (FALSE) {
  obras_es <- gutenberg_works(languages = "es")
  obras_es |>
    filter(grepl("Baroja|Pardo Bazán|Unamuno|Hostos|Martí",
                 author, ignore.case = TRUE)) |>
    select(gutenberg_id, title, author)
}
