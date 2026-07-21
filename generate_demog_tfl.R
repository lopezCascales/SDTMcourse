## =============================================================================
## Programa:   generate_demog_tfl.R
## Proposito:  Generar una tabla TFL de Demografia ("Table 14.1.x") en R,
##             con salida en formato DOCX estilo "submission" (envio regulatorio).
##
## EXPLICACION GENERAL:
##   Este script simula (crea de forma artificial) un dataset de pacientes
##   parecido a un ADSL (el dataset de "subject-level" que se usa en estudios
##   clinicos), calcula estadisticas descriptivas por grupo de tratamiento
##   (n, media, DE, mediana, n (%)), y arma con ellas una tabla de demografia
##   lista para insertar en un documento Word (.docx), tal como se haria para
##   un reporte de un ensayo clinico.
##
##   El flujo general es:
##     1) Cargar/instalar paquetes necesarios
##     2) Definir funciones de ayuda (redondeo estilo SAS)
##     3) Crear datos simulados (reemplazar esto por datos reales despues)
##     4) Calcular resumenes estadisticos por variable (Edad, Sexo, Raza)
##     5) Reorganizar esos resumenes en el formato "ancho" que se ve en una
##        tabla real (una fila por estadistico, una columna por brazo)
##     6) Construir el archivo .docx final con officer + flextable
## =============================================================================

## ---- 0. Paquetes -------------------------------------------------------------
## EXPLICACION: Estas son las librerias de R que el script necesita.
##   - dplyr / tidyr : manipulacion y reorganizacion de datos (filtrar, agrupar,
##                     resumir, pasar de formato largo a ancho, etc.)
##   - officer        : crea y edita documentos Word (.docx) desde R
##   - flextable      : da formato "tabla" (bordes, negritas, encabezados) a un
##                      data frame para poder insertarlo en el Word
##   - purrr          : funciones para iterar (recorrer) datos de forma limpia
##   - stringr        : utilidades para manejar texto (no critico aqui, pero
##                      util si luego se agregan mas transformaciones de texto)
required_pkgs <- c("dplyr", "tidyr", "officer", "flextable", "purrr", "stringr")
to_install <- required_pkgs[!required_pkgs %in% installed.packages()[, "Package"]]
if (length(to_install) > 0) install.packages(to_install)

library(dplyr)
library(tidyr)
library(officer)
library(flextable)
library(purrr)
library(stringr)

## ---- 1. Utilidad: redondeo "hacia afuera de cero" (igual que SAS) -----------
## EXPLICACION: R y SAS redondean distinto cuando el numero termina exactamente
##   en 5 (por ejemplo 2.5). SAS redondea "hacia afuera de cero" (2.5 -> 3),
##   mientras que R por defecto usa el metodo "IEC 60559" que redondea al
##   numero par mas cercano (2.5 -> 2). Esto puede hacer que los numeros de
##   una tabla en R no coincidan con los de SAS. Por eso se crea esta funcion
##   ut_round(), que reproduce el comportamiento de SAS.
ut_round <- function(x, n = 0) {
  scale <- 10^n
  # trunc() corta los decimales; sumar sign(x)*0.5 antes de truncar es el
  # truco que logra el redondeo "hacia afuera de cero" en vez del redondeo
  # bancario que usa round() de R por defecto.
  trunc(x * scale + sign(x) * 0.5) / scale
}

## EXPLICACION: fmt_num() aplica ut_round() y ademas fuerza el numero de
##   decimales visibles (por ejemplo, "8.80" en vez de "8.8"), que es un
##   requisito comun en tablas de estudios clinicos (todas las celdas de una
##   columna deben mostrar el mismo numero de decimales).
fmt_num <- function(x, digits = 1) {
  formatC(ut_round(x, digits), format = "f", digits = digits)
}

## ---- 2. Dataset simulado tipo ADSL -------------------------------------------
## EXPLICACION: Aqui se genera un dataset de pacientes ficticios para poder
##   probar el script sin necesitar datos reales todavia. Cuando tengas datos
##   reales, esta seccion se reemplaza por algo como:
##     adsl <- read.csv("ruta/a/tu/adsl.csv")
##   o bien:
##     adsl <- haven::read_sas("ruta/a/tu/adsl.sas7bdat")
##   siempre y cuando el dataset tenga columnas equivalentes a USUBJID
##   (id del paciente), TRT01P (brazo de tratamiento), AGE, SEX y RACE.
set.seed(123)  # fija la "semilla" aleatoria para que los resultados sean
               # reproducibles cada vez que se corre el script

# EXPLICACION: numero de pacientes por brazo de tratamiento (N total por brazo,
# lo que en las tablas aparece como "(N = 84)", etc. en el encabezado)
n_per_arm <- c(Placebo = 84, "Drug A 100 mg" = 86, "Drug A 200 mg" = 82)

# EXPLICACION: funcion que crea "n" pacientes ficticios para un brazo "trt"
#   dado. AGE se simula con una distribucion normal (rnorm), SEX y RACE se
#   simulan con sample() usando probabilidades aproximadas realistas.
make_arm <- function(trt, n) {
  data.frame(
    USUBJID = paste0("SUBJ-", trt, "-", seq_len(n)),  # id unico por paciente
    TRT01P  = trt,                                      # brazo de tratamiento
    AGE     = round(rnorm(n, mean = 58, sd = 9)),        # edad simulada
    SEX     = sample(c("M", "F"), n, replace = TRUE, prob = c(0.48, 0.52)),
    RACE    = sample(
      c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN", "OTHER"),
      n, replace = TRUE, prob = c(0.7, 0.15, 0.1, 0.05)
    ),
    stringsAsFactors = FALSE
  )
}

# EXPLICACION: map2_dfr() recorre los nombres de los brazos (Placebo, etc.) y
#   sus tamanos (n_per_arm), llama a make_arm() para cada uno, y pega ("dfr" =
#   data frame row-bind) los resultados en un solo data frame.
adsl <- purrr::map2_dfr(names(n_per_arm), n_per_arm, make_arm)

# EXPLICACION: convertir TRT01P en un "factor" con un orden especifico es
#   importante porque, si no, R ordenaria los brazos alfabeticamente
#   ("Drug A 100 mg" antes que "Placebo"), lo cual no es el orden que
#   normalmente se espera en una tabla clinica (Placebo primero, luego dosis
#   creciente).
trt_levels <- c("Placebo", "Drug A 100 mg", "Drug A 200 mg")
adsl$TRT01P <- factor(adsl$TRT01P, levels = trt_levels)

## ---- 3. Funciones de resumen (reutilizables para cualquier variable) --------

## EXPLICACION: summarize_cont() calcula el resumen estandar para una variable
##   CONTINUA (numerica), como la Edad: cuantos pacientes tienen dato (n),
##   media, desviacion estandar (sd), mediana, minimo y maximo, todo separado
##   por brazo de tratamiento (group_by(TRT01P)). El argumento ".drop = FALSE"
##   asegura que, si algun brazo tuviera 0 pacientes con datos, igual aparezca
##   en la tabla (en vez de desaparecer silenciosamente).
summarize_cont <- function(data, var, label) {
  data %>%
    group_by(TRT01P, .drop = FALSE) %>%
    summarise(
      n      = sum(!is.na(.data[[var]])),
      mean   = mean(.data[[var]], na.rm = TRUE),
      sd     = sd(.data[[var]], na.rm = TRUE),
      median = median(.data[[var]], na.rm = TRUE),
      min    = min(.data[[var]], na.rm = TRUE),
      max    = max(.data[[var]], na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      label = label,
      # EXPLICACION: aqui ya se arman los textos exactos que van a aparecer
      # en la tabla final, por ejemplo "58.3 (9.12)" para Media (DE), usando
      # fmt_num() para que el redondeo y los decimales sean consistentes.
      stat_n         = paste0("n = ", n),
      stat_mean_sd   = paste0(fmt_num(mean, 1), " (", fmt_num(sd, 2), ")"),
      stat_med_range = paste0(fmt_num(median, 1), " (", fmt_num(min, 1), ", ", fmt_num(max, 1), ")")
    )
}

## EXPLICACION: summarize_cat() hace lo mismo pero para una variable
##   CATEGORICA (por ejemplo Sexo o Raza): cuenta cuantos pacientes hay en
##   cada categoria, por brazo, y calcula el porcentaje sobre el total de
##   ese brazo (no sobre el total del estudio). El resultado es el texto
##   estandar "n (%)" que se ve en las tablas clinicas, por ejemplo "42 (50.0%)".
summarize_cat <- function(data, var, label) {
  # total de pacientes por brazo (el denominador del porcentaje)
  total_by_arm <- data %>% count(TRT01P, .drop = FALSE, name = "N_arm")

  data %>%
    count(TRT01P, .data[[var]], .drop = FALSE, name = "n") %>%
    left_join(total_by_arm, by = "TRT01P") %>%
    mutate(
      pct = 100 * n / N_arm,
      stat = paste0(n, " (", fmt_num(pct, 1), "%)"),
      label = label
    ) %>%
    rename(category = all_of(var))
}

## ---- 4. Construir el cuerpo de la tabla --------------------------------------
## EXPLICACION: en esta seccion se llama a las funciones de resumen para cada
##   variable de interes (Edad, Sexo, Raza), y luego se "reorganiza" cada
##   resumen para que quede en el formato final: una fila por estadistico,
##   una columna por brazo de tratamiento. Este paso de reorganizar (usando
##   pivot_wider) es necesario porque summarize_cont()/summarize_cat()
##   devuelven los datos en formato "largo" (una fila por combinacion
##   brazo-estadistico), que es comodo para calcular pero no es como se ve
##   una tabla real.

age_summary <- summarize_cont(adsl, "AGE", "Age (years)")

sex_summary <- summarize_cat(adsl, "SEX", "Sex, n (%)") %>%
  mutate(category = recode(category, "M" = "Male", "F" = "Female"))

race_summary <- summarize_cat(adsl, "RACE", "Race, n (%)")

# --- Bloque "Edad": reorganizar n / media(DE) / mediana(min,max) por brazo ---
# EXPLICACION: pivot_longer() junta las tres columnas de estadisticas
#   (stat_n, stat_mean_sd, stat_med_range) en una sola columna "value", y
#   luego pivot_wider() las separa por brazo de tratamiento (una columna por
#   brazo). El resultado final tiene 3 filas (n, Media (DE), Mediana) y una
#   columna por cada brazo.
age_wide <- age_summary %>%
  select(TRT01P, stat_n, stat_mean_sd, stat_med_range) %>%
  pivot_longer(cols = c(stat_n, stat_mean_sd, stat_med_range), names_to = "stat_type", values_to = "value") %>%
  pivot_wider(names_from = TRT01P, values_from = value) %>%
  mutate(
    row_label = recode(stat_type,
      "stat_n"         = "  n",
      "stat_mean_sd"   = "  Mean (SD)",
      "stat_med_range" = "  Median (Min, Max)"
    )
  ) %>%
  select(row_label, all_of(trt_levels))

# EXPLICACION: esta fila es el "titulo de seccion" dentro de la tabla, por
#   ejemplo "Age (years)" en negrita, sin numeros, solo para separar
#   visualmente el bloque de Edad de los demas bloques (Sexo, Raza).
age_header <- tibble(row_label = "Age (years)", !!!setNames(rep("", length(trt_levels)), trt_levels))

# --- Bloque "Sexo": reorganizar por brazo ---
sex_wide <- sex_summary %>%
  select(TRT01P, category, stat) %>%
  pivot_wider(names_from = TRT01P, values_from = stat) %>%
  rename(row_label = category) %>%
  mutate(row_label = paste0("  ", row_label)) %>%  # sangria para "anidar" bajo el titulo de seccion
  select(row_label, all_of(trt_levels))

sex_header <- tibble(row_label = "Sex, n (%)", !!!setNames(rep("", length(trt_levels)), trt_levels))

# --- Bloque "Raza": reorganizar por brazo ---
race_wide <- race_summary %>%
  select(TRT01P, category, stat) %>%
  pivot_wider(names_from = TRT01P, values_from = stat) %>%
  rename(row_label = category) %>%
  mutate(row_label = paste0("  ", row_label)) %>%
  select(row_label, all_of(trt_levels))

race_header <- tibble(row_label = "Race, n (%)", !!!setNames(rep("", length(trt_levels)), trt_levels))

# --- Fila de encabezado: N total por brazo (arriba de todo) ---
n_header <- adsl %>%
  count(TRT01P, .drop = FALSE) %>%
  pivot_wider(names_from = TRT01P, values_from = n) %>%
  mutate(row_label = "n") %>%
  select(row_label, all_of(trt_levels))

# EXPLICACION: bind_rows() apila todas las piezas anteriores, en el orden en
#   que queremos que aparezcan en la tabla final: primero el total (n),
#   luego el bloque de Edad (titulo + sus 3 filas), luego Sexo, luego Raza.
tbl_body <- bind_rows(
  n_header,
  age_header, age_wide,
  sex_header, sex_wide,
  race_header, race_wide
)

## ---- 5. Construir el DOCX con officer + flextable ----------------------------
## EXPLICACION: hasta aqui, tbl_body es solo un data frame con texto (todavia
##   no tiene ningun formato visual). En esta seccion se convierte ese data
##   frame en una tabla con estilo (flextable) y se inserta dentro de un
##   documento Word (officer), agregando titulo, subtitulo y pie de tabla
##   (footnote), tal como se veria en un reporte real.

title_text    <- "Table 14.1.1"
subtitle_text <- "Summary of Demographic and Baseline Characteristics"
subtitle2     <- "(Safety Population)"
footnote_text <- "Percentages are based on the number of subjects in each treatment group."

# EXPLICACION: aqui se arman los textos de encabezado de columna, por ejemplo
#   "Placebo\n(N = 84)" (con un salto de linea antes del "N ="), que es el
#   formato tipico de encabezado en tablas clinicas.
header_labels <- c(
  list(row_label = ""),
  setNames(
    as.list(sprintf("%s\n(N = %s)", trt_levels, n_per_arm[trt_levels])),
    trt_levels
  )
)

ft <- flextable(tbl_body)
# EXPLICACION: se usa do.call() en vez de pasar los nombres directamente
#   porque los nombres de brazo (ej. "Drug A 100 mg") tienen espacios, y eso
#   no es valido como nombre de argumento "suelto" en una llamada de funcion
#   normal en R; do.call() permite pasar una lista con esos nombres sin
#   problema.
ft <- do.call(set_header_labels, c(list(x = ft), header_labels))

ft <- ft %>%
  align(align = "center", part = "header") %>%     # centrar texto del encabezado
  align(j = 2:4, align = "center", part = "body") %>%  # centrar columnas de datos (brazos)
  align(j = 1, align = "left", part = "body") %>%      # alinear a la izquierda la columna de etiquetas
  # EXPLICACION: poner en negrita las filas que son "titulo de seccion"
  # (Age, Sex, Race, n), para que se distingan de las filas de detalle.
  bold(i = ~ row_label %in% c("Age (years)", "Sex, n (%)", "Race, n (%)", "n"), j = 1) %>%
  fontsize(size = 9, part = "all") %>%
  font(fontname = "Times New Roman", part = "all") %>%
  autofit() %>%
  border_remove() %>%
  hline_top(part = "header", border = fp_border(width = 1.5)) %>%
  hline_bottom(part = "header", border = fp_border(width = 1)) %>%
  hline_bottom(part = "body", border = fp_border(width = 1.5)) %>%
  add_footer_lines(footnote_text) %>%
  fontsize(size = 8, part = "footer") %>%
  font(fontname = "Times New Roman", part = "footer")

## EXPLICACION: read_docx() crea un documento Word en blanco, y body_add_par()
##   le va agregando parrafos (titulo, subtitulos), luego body_add_flextable()
##   inserta la tabla ya formateada. body_end_section_landscape() pone la
##   pagina en orientacion horizontal (util cuando la tabla es ancha).
doc <- read_docx() %>%
  body_add_par(title_text, style = "heading 1") %>%
  body_add_par(subtitle_text, style = "heading 2") %>%
  body_add_par(subtitle2, style = "heading 2") %>%
  body_add_par("", style = "Normal") %>%
  body_add_flextable(ft) %>%
  body_end_section_landscape()   # opcional: orientacion horizontal para tablas anchas

out_path <- "demographics_table_14_1_1.docx"
print(doc, target = out_path)  # EXPLICACION: esto escribe el archivo .docx final en disco

message("TFL table written to: ", normalizePath(out_path))
