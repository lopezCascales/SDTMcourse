## =============================================================================
## Programa:   generate_ae_tfl.R
## Proposito:  Generar una tabla TFL de Eventos Adversos ("Table 14.3.x") en R,
##             con salida en formato DOCX estilo "submission".
##
## EXPLICACION GENERAL:
##   Este script simula un dataset de eventos adversos (parecido a un ADAE),
##   y calcula la "incidencia" (n (%) de pacientes con al menos un evento) por
##   Clase de Organo del Sistema (SOC) y Termino Preferido (PT), separado por
##   brazo de tratamiento. Ademas ordena los eventos por frecuencia en el
##   brazo de dosis mas alta, que es una convencion comun al reportar
##   seguridad en ensayos clinicos.
##
##   Punto clave que lo distingue de un conteo simple: un paciente que tuvo
##   el mismo evento adverso 3 veces cuenta como "1" (una persona), no como 3.
##   Por eso se usa distinct(USUBJID, ...) antes de contar.
## =============================================================================

## ---- 0. Paquetes -------------------------------------------------------------
## EXPLICACION: mismas librerias que en el script de demografia (ver ese
##   archivo para el detalle de cada una), mas purrr para iterar sobre la
##   lista de eventos adversos posibles.
required_pkgs <- c("dplyr", "tidyr", "officer", "flextable", "purrr")
to_install <- required_pkgs[!required_pkgs %in% installed.packages()[, "Package"]]
if (length(to_install) > 0) install.packages(to_install)

library(dplyr)
library(tidyr)
library(officer)
library(flextable)
library(purrr)

## ---- 1. Utilidad: redondeo "hacia afuera de cero" (igual que SAS) -----------
## EXPLICACION: identica logica que en generate_demog_tfl.R. Ver ese archivo
##   para la explicacion completa de por que hace falta esta funcion.
ut_round <- function(x, n = 0) {
  scale <- 10^n
  trunc(x * scale + sign(x) * 0.5) / scale
}

fmt_num <- function(x, digits = 1) {
  formatC(ut_round(x, digits), format = "f", digits = digits)
}

## ---- 2. Datasets simulados: ADSL (pacientes) + ADAE (eventos) --------------
set.seed(123)

trt_levels <- c("Placebo", "Drug A 100 mg", "Drug A 200 mg")
n_per_arm  <- c(Placebo = 84, "Drug A 100 mg" = 86, "Drug A 200 mg" = 82)

# EXPLICACION: adsl aqui es minimo (solo USUBJID y TRT01P) porque para esta
#   tabla de eventos adversos solo necesitamos saber cuantos pacientes hay
#   en total por brazo (el denominador de los porcentajes), no su edad/sexo/etc.
adsl <- purrr::map2_dfr(names(n_per_arm), n_per_arm, function(trt, n) {
  data.frame(
    USUBJID = paste0("SUBJ-", trt, "-", seq_len(n)),
    TRT01P  = trt,
    stringsAsFactors = FALSE
  )
})
adsl$TRT01P <- factor(adsl$TRT01P, levels = trt_levels)

# EXPLICACION: este es el "diccionario" de eventos adversos posibles: para
#   cada combinacion de SOC (Clase de Organo del Sistema) y PT (Termino
#   Preferido), se define una probabilidad de ocurrencia distinta por brazo
#   (p_pbo = probabilidad en Placebo, p_100 = en dosis de 100mg, p_200 = en
#   dosis de 200mg). Las probabilidades suben con la dosis para simular un
#   perfil de seguridad plausible (mas eventos a mayor dosis).
ae_dict <- tibble::tribble(
  ~SOC,                                  ~PT,                         ~p_pbo, ~p_100, ~p_200,
  "Gastrointestinal disorders",          "Nausea",                    0.10,   0.18,   0.27,
  "Gastrointestinal disorders",          "Diarrhoea",                 0.08,   0.12,   0.15,
  "Gastrointestinal disorders",          "Vomiting",                  0.05,   0.07,   0.10,
  "Nervous system disorders",            "Headache",                 0.15,   0.20,   0.22,
  "Nervous system disorders",            "Dizziness",                0.06,   0.09,   0.13,
  "General disorders",                   "Fatigue",                  0.09,   0.11,   0.16,
  "General disorders",                   "Injection site reaction",  0.03,   0.14,   0.19,
  "Infections and infestations",         "Nasopharyngitis",          0.11,   0.10,   0.09,
  "Infections and infestations",         "Upper respiratory infection", 0.07, 0.08,  0.08,
  "Skin and subcutaneous tissue disorders", "Rash",                  0.04,   0.08,   0.12
)

# EXPLICACION: esta funcion recorre cada fila del diccionario ae_dict (cada
#   combinacion SOC/PT), y para cada paciente hace un "sorteo" (rbinom, como
#   tirar una moneda cargada) para decidir si ese paciente tuvo o no ese
#   evento, segun la probabilidad de su brazo. filter(occurred == 1) se queda
#   solo con los pacientes a los que "les toco" el evento. El resultado final
#   es una tabla con una fila por cada (paciente, evento) que realmente
#   ocurrio -- exactamente la forma en que se veria un ADAE real.
simulate_ae_occurrences <- function(adsl, ae_dict) {
  purrr::pmap_dfr(ae_dict, function(SOC, PT, p_pbo, p_100, p_200) {
    p_map <- c(Placebo = p_pbo, "Drug A 100 mg" = p_100, "Drug A 200 mg" = p_200)
    adsl %>%
      mutate(occurred = rbinom(n(), 1, p_map[as.character(TRT01P)])) %>%
      filter(occurred == 1) %>%
      transmute(USUBJID, TRT01P, SOC = SOC, PT = PT)
  })
}

adae <- simulate_ae_occurrences(adsl, ae_dict)

## ---- 3. Funcion de ayuda: resumen de incidencia (n (%) de pacientes) -------
## EXPLICACION: esta es la funcion clave de la tabla de eventos adversos.
##   Cuenta PACIENTES (no eventos) que tuvieron al menos una ocurrencia de
##   cada categoria (SOC o PT), y calcula el porcentaje sobre el total de
##   pacientes de ese brazo (denom). El parametro group_var indica si estamos
##   resumiendo por "SOC" o por "PT" -- la misma funcion sirve para ambos
##   niveles de la tabla.
summarize_incidence <- function(adae, adsl, group_var, label_var = NULL) {
  # denominador por brazo: TODOS los pacientes del estudio en ese brazo,
  # hayan tenido o no un evento adverso (poblacion de seguridad completa)
  denom <- adsl %>% count(TRT01P, .drop = FALSE, name = "N_arm")

  adae %>%
    # EXPLICACION: distinct() aqui es el paso mas importante: si un mismo
    # paciente aparece varias veces con el mismo SOC/PT (por ejemplo,
    # "Nausea" registrada 3 veces), distinct() lo deja como una sola fila,
    # para que ese paciente cuente una sola vez.
    distinct(USUBJID, TRT01P, .data[[group_var]]) %>%
    count(TRT01P, .data[[group_var]], .drop = FALSE, name = "n") %>%
    left_join(denom, by = "TRT01P") %>%
    mutate(
      pct  = 100 * n / N_arm,
      stat = paste0(n, " (", fmt_num(pct, 1), "%)")
    ) %>%
    rename(row_group = all_of(group_var))
}

## ---- 4. Fila "General": subjects with >=1 adverse event --------------------
## EXPLICACION: esta es la primera fila de la tabla, el resumen mas general
##   posible: cuantos pacientes tuvieron AL MENOS UN evento adverso de
##   cualquier tipo (sin importar cual), por brazo.
overall_ae <- adae %>%
  distinct(USUBJID, TRT01P) %>%
  count(TRT01P, .drop = FALSE, name = "n") %>%
  left_join(adsl %>% count(TRT01P, .drop = FALSE, name = "N_arm"), by = "TRT01P") %>%
  mutate(
    pct  = 100 * n / N_arm,
    stat = paste0(n, " (", fmt_num(pct, 1), "%)"),
    row_label = "Subjects with >=1 adverse event"
  ) %>%
  select(TRT01P, row_label, stat) %>%
  pivot_wider(names_from = TRT01P, values_from = stat) %>%
  select(row_label, all_of(trt_levels))

## ---- 5. Resumenes por SOC y por PT, ordenados por incidencia -------------

soc_summary <- summarize_incidence(adae, adsl, group_var = "SOC") %>%
  rename(SOC = row_group)

pt_summary <- summarize_incidence(adae, adsl, group_var = "PT") %>%
  rename(PT = row_group) %>%
  left_join(distinct(ae_dict, SOC, PT), by = "PT")

# EXPLICACION: aqui se decide el ORDEN en que aparecen las Clases de Organo
#   del Sistema (SOC) en la tabla: de mayor a menor frecuencia en el brazo de
#   dosis MAS ALTA (Drug A 200 mg). Esta es una convencion muy comun en
#   tablas de seguridad, para que los eventos mas relevantes para el
#   tratamiento activo aparezcan primero.
soc_order <- soc_summary %>%
  filter(TRT01P == "Drug A 200 mg") %>%
  arrange(desc(n)) %>%
  pull(SOC)

# EXPLICACION: dentro de cada SOC, se aplica el mismo criterio de orden a
#   los PT (Terminos Preferidos) que pertenecen a esa SOC.
pt_order <- pt_summary %>%
  filter(TRT01P == "Drug A 200 mg") %>%
  arrange(SOC, desc(n)) %>%
  distinct(SOC, PT) %>%
  mutate(SOC = factor(SOC, levels = soc_order)) %>%
  arrange(SOC) %>%
  pull(PT)

# EXPLICACION: reorganizar el resumen de SOC a formato ancho (una columna
#   por brazo), igual que se hizo en el script de demografia.
soc_wide <- soc_summary %>%
  select(TRT01P, SOC, stat) %>%
  pivot_wider(names_from = TRT01P, values_from = stat) %>%
  mutate(row_label = SOC, block_type = "SOC") %>%
  select(row_label, block_type, all_of(trt_levels), SOC)

pt_wide <- pt_summary %>%
  select(TRT01P, PT, SOC, stat) %>%
  pivot_wider(names_from = TRT01P, values_from = stat) %>%
  mutate(row_label = paste0("  ", PT), block_type = "PT") %>%
  select(row_label, block_type, all_of(trt_levels), SOC)

# EXPLICACION: aqui se "intercalan" las filas en el orden final de la tabla:
#   para cada SOC (en el orden de soc_order), primero se pone la fila de
#   encabezado de esa SOC, y luego sus PT correspondientes (tambien
#   ordenados por frecuencia). map_dfr() recorre cada SOC y va apilando el
#   resultado.
body_rows <- purrr::map_dfr(soc_order, function(this_soc) {
  soc_row <- soc_wide %>% filter(SOC == this_soc)
  pt_rows <- pt_wide %>%
    filter(SOC == this_soc) %>%
    mutate(PT_order = match(sub("^  ", "", row_label), pt_order)) %>%
    arrange(PT_order) %>%
    select(-PT_order)
  bind_rows(soc_row, pt_rows)
}) %>%
  select(row_label, all_of(trt_levels))

# EXPLICACION: se junta la fila general ("Subjects with >=1 adverse event")
#   con todos los bloques SOC/PT ya ordenados, para formar el cuerpo final
#   de la tabla.
tbl_body <- bind_rows(overall_ae, body_rows)

## ---- 6. Construir el DOCX con officer + flextable ----------------------------
## EXPLICACION: mismo patron que en el script de demografia: se arma el
##   texto de titulo/subtitulo/footnote, se crea la flextable con encabezados
##   de columna (marca y N por brazo), se aplican negritas a las filas de
##   SOC (para distinguirlas visualmente de las filas de PT), y se inserta
##   todo en un documento Word.

title_text    <- "Table 14.3.1"
subtitle_text <- "Summary of Treatment-Emergent Adverse Events by System Organ Class and Preferred Term"
subtitle2     <- "(Safety Population)"
footnote_text <- paste(
  "A subject is counted only once within each System Organ Class and Preferred Term, even if the subject",
  "experienced multiple occurrences of the event. Percentages are based on the number of subjects in each",
  "treatment group."
)

header_labels <- c(
  list(row_label = ""),
  setNames(
    as.list(sprintf("%s\n(N = %s)", trt_levels, n_per_arm[trt_levels])),
    trt_levels
  )
)

ft <- flextable(tbl_body)
ft <- do.call(set_header_labels, c(list(x = ft), header_labels))

# EXPLICACION: se identifican los numeros de fila (indices) que corresponden
#   a titulos de SOC (para ponerlos en negrita), distinguiendolos de las
#   filas de PT (que llevan sangria "  " al inicio del texto) y de la fila
#   general de "Subjects with >=1 adverse event".
soc_row_idx <- which(!startsWith(tbl_body$row_label, "  ") &
                        tbl_body$row_label != "Subjects with >=1 adverse event")

ft <- ft %>%
  align(align = "center", part = "header") %>%
  align(j = 2:4, align = "center", part = "body") %>%
  align(j = 1, align = "left", part = "body") %>%
  bold(i = soc_row_idx, j = 1) %>%
  bold(i = which(tbl_body$row_label == "Subjects with >=1 adverse event"), j = 1) %>%
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

doc <- read_docx() %>%
  body_add_par(title_text, style = "heading 1") %>%
  body_add_par(subtitle_text, style = "heading 2") %>%
  body_add_par(subtitle2, style = "heading 2") %>%
  body_add_par("", style = "Normal") %>%
  body_add_flextable(ft) %>%
  body_end_section_landscape()

out_path <- "ae_table_14_3_1.docx"
print(doc, target = out_path)

message("TFL table written to: ", normalizePath(out_path))
