# Taller Introducción a R — CACCS · FCS · UPR-RP

**Centro Académico de Cómputos · Facultad de Ciencias Sociales · Universidad de Puerto Rico, Recinto de Río Piedras**

- **Fecha**: viernes 17 de abril de 2026
- **Hora**: 10:00 a.m. – 12:00 p.m.
- **Salón**: REB-120
- **Recurso**: Dr. Rashid C.J. Marcano Rivera (Sociología, FCS-UPRRP)
- **Coordinación**: `caccs.rp@upr.edu` · Ext. 87751 · <http://sociales.uprrp.edu/caccs>

## Sobre el taller

Introducción práctica a R y RStudio para personas en Ciencias Sociales y Humanidades. La sesión combina dos hilos sustantivos:

1. **Hilo cuantitativo (política comparada)**: encuesta del referéndum chileno de 1988 (`carData::Chile`, 2.700 obs) — exploración con `tidyverse`, visualización con `ggplot2` y un modelo lineal sobre el apoyo al régimen militar.
2. **Hilo cualitativo (humanidades digitales)**: comparación de frecuencias léxicas entre *Don Quijote de la Mancha* (Cervantes, 1605) y *Fortunata y Jacinta* (Galdós, 1887). Ambos textos vienen pre-descargados.

### Base bibliográfica

La parte introductoria (instalación, RStudio, calculadora, asignación, vectores, funciones, tipos de datos, conceptos básicos de programación) sigue los **capítulos 1–3** del libro de **Rafael A. Irizarry, *Introducción a la ciencia de datos*** (Harvard, edición en español, gratuito): <https://rafalab.dfci.harvard.edu/dslibro/>. Los casos sustantivos (Chile 1988, Cervantes/Galdós) y la adaptación a CSyH son contribución del autor.

## Agenda (120 minutos)

| Bloque | Min     | Tema                                            |
|--------|---------|-------------------------------------------------|
| 0      | 0–5     | Bienvenida y por qué R en CSyH                  |
| 1      | 5–20    | RStudio + R como calculadora                    |
| 2      | 20–40   | Importar y explorar datos (encuesta Chile 1988) |
| 3      | 40–60   | Tidyverse — cinco verbos                        |
| 4      | 60–80   | Visualización con `ggplot2`                     |
| 5      | 80–95   | Modelo lineal: economía política del voto       |
| 6      | 95–115  | Comparación de corpus: Cervantes vs. Galdós     |
| 7      | 115–120 | Recursos y cierre                               |

> **Plan B**: si los bloques 1–4 se extienden, el bloque 6 puede recortarse a una demo de 8 minutos centrada solo en la tabla de palabras distintivas; el bloque 5 puede reducirse al `summary(modelo)` sin la tabla `broom` ni el forest plot.

## Antes del taller

1. **Instalar R**: <https://cran.r-project.org/>
2. **Instalar RStudio Desktop**: <https://posit.co/download/rstudio-desktop/>
3. **Configurar UTF-8 en RStudio** (una sola vez):

   **Tools → Global Options → Code → Saving → Default text encoding: UTF-8**

   El material del taller usa nombres de objetos en español (`año_referéndum`, `educación`). R los acepta sin problema, pero el archivo debe leerse en UTF-8. Si en algún momento abren un *script* y ven símbolos raros (`â€`, `Ã±`), recárguenlo con **File → Reopen with Encoding → UTF-8**.

4. **Correr `instalacion.R`** una sola vez para instalar los paquetes:

   ```r
   source("instalacion.R")
   ```

   El script verifica qué falta y solo instala lo necesario. Termina imprimiendo un resumen con `OK` o `FALTA` para cada paquete.

> Si prefieren no instalar nada localmente, pueden usar [Posit Cloud](https://posit.cloud/) en el navegador con una cuenta gratuita (UTF-8 viene por defecto).

## Archivos del taller

| Archivo                            | Para qué sirve                                                                    |
|------------------------------------|-----------------------------------------------------------------------------------|
| `taller_intro_R_2026-04-17.qmd`    | Documento maestro Quarto. Renderiza a HTML con narrativa, código y resultados.    |
| `taller_intro_R_2026-04-17.R`      | Script con los mismos chunks, sin prosa. Útil para quienes prefieren un solo archivo. |
| `tema-caccs.scss`                  | Tema visual del documento (rojo institucional UPRRP, fuentes locales).            |
| `instalacion.R`                    | Instala los paquetes necesarios.                                                  |
| `datos/chile.csv`                  | Encuesta Chile 1988 exportada a CSV (demo de `read_csv`).                         |
| `datos/quijote.rds`                | *Don Quijote* pre-descargado (Cervantes, 1605, ~37k líneas).                      |
| `datos/fortunata.rds`              | *Fortunata y Jacinta* pre-descargada (Galdós, 1887, ~42k líneas).                 |

## Cómo abrir y ejecutar

1. Abrir RStudio.
2. **File > Open File** (o doble clic en `taller_intro_R_2026-04-17.qmd`).
3. Renderizar el HTML: botón **Render** en RStudio, o desde terminal:

   ```bash
   quarto render taller_intro_R_2026-04-17.qmd
   ```

4. Para ejecutar línea por línea durante la sesión: abran el `.R` y usen **Cmd+Return** (Mac) o **Ctrl+Enter** (PC).

> **Importante**: la sesión asume que el directorio de trabajo es la raíz del taller. Las rutas relativas (`datos/chile.csv`, `datos/quijote.rds`, `datos/fortunata.rds`) dependen de eso. En RStudio: **Session > Set Working Directory > To Source File Location**.

## Paquetes utilizados

```r
tidyverse     # dplyr + ggplot2 + readr + amigos
scales        # formato de ejes (porcentajes)
carData       # encuesta Chile 1988
broom         # tablas tidy de modelos
haven         # importar SPSS y Stata (opcional)
readxl        # importar Excel (opcional)
gutenbergr    # Proyecto Gutenberg
tidytext      # tokenización
stopwords     # palabras vacías por idioma
ragg          # dispositivo gráfico con buen soporte Unicode
rmarkdown     # render fallback
```

## Recursos para continuar

- **R for Data Science** (Wickham et al., 2e) — <https://r4ds.hadley.nz/>
- **Introducción a la ciencia de datos** (Irizarry, español) — <https://rafalab.dfci.harvard.edu/dslibro/>
- **Text Mining with R** (Silge & Robinson) — <https://www.tidytextmining.com/>
- **An R Companion to Applied Regression** (Fox & Weisberg) — <https://socialsciences.mcmaster.ca/jfox/Books/Companion/>
- **Hojas de referencia rápida** (Posit) — <https://posit.co/resources/cheatsheets/>
- **Proyecto Gutenberg en español** — <https://www.gutenberg.org/browse/languages/es>
- **StackOverflow, etiqueta R** — <https://stackoverflow.com/questions/tagged/r>

## Contacto

Dudas, sugerencias o preguntas: <rashid.marcano@upr.edu>
