## =============================================================================
## Programa:   generate_lsm_tfl.R
## Proposito:  Generar una tabla TFL de analisis LSM/ANCOVA ("Table 14.2.x")
##             de cambio desde basal, en R, con salida en formato DOCX.
##
## EXPLICACION GENERAL:
##   Este script reproduce el enfoque del paper de PhUSE CT05 (seccion
##   "ANCOVA sin medidas repetidas"): ajusta un modelo lineal (lm) con el
##   cambio desde basal como variable respuesta, y usa emmeans() para
##   calcular las Medias de Minimos Cuadrados (LS Means o LSM) -- que son
##   las medias "ajustadas" por las otras variables del modelo (basal,
##   visita, tratamiento) -- junto con su error estandar y el p-valor de
##   comparar cada dosis contra Placebo.
##
##   Segun el paper original, este enfoque (sin medidas repetidas) es el
##   caso en el que R y SAS (PROC MIXED) coinciden al 100% en los resultados,
##   por eso se eligio como ejemplo aqui.
## =============================================================================

## ---- 0. Paquetes -------------------------------------------------------------
## EXPLICACION: ademas de dplyr/tidyr/officer/flextable (ver script de
##   demografia para el detalle), aqui se agrega "emmeans", que es el
##   paquete de R que calcula las Medias de Minimos Cuadrados (LS Means) y
##   sus comparaciones, equivalente a la instruccion "lsmeans" de SAS.
required_pkgs <- c("dplyr", "tidyr", "officer", "flextable", "emmeans", "purrr")
to_install <- required_pkgs[!required_pkgs %in% installed.packages()[, "Package"]]
if (length(to_install) > 0) install.packages(to_install)

library(dplyr)
library(tidyr)
library(officer)
library(flextable)
library(emmeans)
library(purrr)

## ---- 1. Utilidad: redondeo "hacia afuera de cero" (igual que SAS) -----------
## EXPLICACION: misma logica que en los otros dos scripts (ver
##   generate_demog_tfl.R para el detalle completo de por que hace falta).
ut_round <- function(x, n = 0) {
  scale <- 10^n
  trunc(x * scale + sign(x) * 0.5) / scale
}

fmt_num <- function(x, digits = 1) {
  formatC(ut_round(x, digits), format = "f", digits = digits)
}

## EXPLICACION: fmt_pval() da formato especial a los p-valores: si el
##   p-valor es muy chico (por debajo de 0.0001, por ejemplo), en vez de
##   mostrar "0.0000" (que se ve raro/confuso), muestra "<0.0001", que es
##   el formato estandar esperado en tablas clinicas.
fmt_pval <- function(p, digits = 4) {
  out <- fmt_num(p, digits)
  ifelse(p < 10^(-digits), paste0("<", formatC(10^(-digits), format = "f", digits = digits)), out)
}

## ---- 2. Dataset simulado tipo BDS (basal + cambio, por visita) --------------
## EXPLICACION: a diferencia de los otros dos scripts, aqui necesitamos datos
##   LONGITUDINALES: cada paciente aparece varias veces (una fila por visita),
##   con su valor basal (BASE, constante para el paciente) y su cambio desde
##   basal en esa visita (CHG). Esto imita un dataset "BDS" (Basic Data
##   Structure) de ADaM, tipico para analisis de eficacia.
set.seed(123)

trt_levels  <- c("Placebo", "Drug A 100 mg", "Drug A 200 mg")
visit_levels <- c("Week 4", "Week 8", "Week 12")
n_per_arm   <- c(Placebo = 84, "Drug A 100 mg" = 86, "Drug A 200 mg" = 82)

# EXPLICACION: aqui se define el "efecto de tratamiento" simulado -- el
#   cambio promedio esperado en cada brazo, en cada visita. Los valores son
#   inventados para que Drug A 200mg tenga el mayor efecto, seguido de
#   Drug A 100mg, y Placebo con el menor efecto (mas cercano a cero), y para
#   que el efecto se haga mas grande con el tiempo (semana 4 -> 8 -> 12).
#   Esto simplemente da forma a los datos simulados; con datos reales, este
#   "efecto" surge naturalmente de las mediciones de los pacientes.
trt_effect <- list(
  "Placebo"       = c(-1.0, -1.2, -1.3),
  "Drug A 100 mg" = c(-2.0, -3.0, -3.8),
  "Drug A 200 mg" = c(-2.5, -4.2, -5.5)
)

# EXPLICACION: para cada brazo, se simula un valor BASAL por paciente (que
#   no cambia entre visitas, como corresponde a un valor "basal"), y luego,
#   para cada una de las 3 visitas, se simula el cambio (CHG) sumando el
#   "efecto de tratamiento" de esa visita mas ruido aleatorio (variabilidad
#   individual entre pacientes).
make_subject_data <- function(trt, n) {
  base <- rnorm(n, mean = 100, sd = 12)
  purrr::map_dfr(seq_along(visit_levels), function(v) {
    eff <- trt_effect[[trt]][v]
    data.frame(
      USUBJID  = paste0("SUBJ-", trt, "-", seq_len(n)),
      TRT01P   = trt,
      AVISIT   = visit_levels[v],
      BASE     = base,
      CHG      = eff + rnorm(n, mean = 0, sd = 4),
      stringsAsFactors = FALSE
    )
  })
}

adbds <- purrr::map2_dfr(names(n_per_arm), n_per_arm, make_subject_data)

adbds$TRT01P <- factor(adbds$TRT01P, levels = trt_levels)
adbds$AVISIT <- factor(adbds$AVISIT, levels = visit_levels)

## ---- 3. Funcion de ayuda: ajustar ANCOVA (sin medidas repetidas) -----------
## EXPLICACION: esta funcion reproduce el CASO 1 del paper CT05 (sin medidas
##   repetidas):
##     En SAS seria:  proc mixed; model chg = base visitcn trtn trtn*visitcn;
##     En R:          lm(CHG ~ BASE + AVISIT + TRT01P + TRT01P*AVISIT)
##   Es decir, el cambio (CHG) se explica por: el valor basal (BASE), la
##   visita (AVISIT), el tratamiento (TRT01P), y la interaccion entre
##   tratamiento y visita (TRT01P*AVISIT) -- esto ultimo permite que el
##   efecto del tratamiento sea distinto en cada visita.
fit_ancova_lsm <- function(data, ref_level = "Placebo") {
  # EXPLICACION: relevel() define cual es el brazo de referencia (Placebo)
  #   para que las comparaciones de p-valor se hagan "cada dosis vs Placebo"
  #   y no en otro orden.
  data$TRT01P <- relevel(data$TRT01P, ref = ref_level)

  model <- lm(CHG ~ BASE + AVISIT + TRT01P + TRT01P * AVISIT, data = data)

  # EXPLICACION: emmeans() calcula la LSM (media ajustada por el modelo) del
  #   cambio, para cada combinacion de Tratamiento x Visita, junto con su
  #   error estandar (SE). Estas son las "medias ajustadas", no simplemente
  #   el promedio bruto de los datos -- por eso pueden diferir un poco de un
  #   promedio simple, ya que tienen en cuenta el valor basal de cada
  #   paciente.
  lsm <- emmeans(model, ~ TRT01P * AVISIT)
  lsm_df <- as.data.frame(lsm) %>%
    rename(LSM_CHG = emmean, LSM_CHG_SE = SE)

  # EXPLICACION: aqui se calculan las comparaciones de a pares (pairwise)
  #   entre tratamientos, DENTRO de cada visita ("| AVISIT" significa
  #   "separado por visita"). adjust = "none" indica que no se aplica ningun
  #   ajuste por comparaciones multiples (p-valores "crudos"), igual que en
  #   el ejemplo del paper original.
  contrasts <- emmeans(model, revpairwise ~ TRT01P | AVISIT, adjust = "none")
  pval_df <- as.data.frame(contrasts$contrasts) %>%
    # EXPLICACION: emmeans genera comparaciones en ambas direcciones
    # (ej. "100mg - Placebo" y "Placebo - 100mg"); este filtro se queda
    # solo con las comparaciones "cada dosis - Placebo".
    filter(grepl(paste0(" - ", ref_level, "$"), contrast)) %>%
    mutate(TRT01P = sub(paste0(" - ", ref_level), "", contrast)) %>%
    select(TRT01P, AVISIT, p.value)

  list(lsm = lsm_df, pval = pval_df)
}

results <- fit_ancova_lsm(adbds, ref_level = "Placebo")

## ---- 4. Construir el cuerpo de la tabla: LSM (SE) y p-valor, por visita ----
## EXPLICACION: igual que en los otros scripts, aqui se toman los resultados
##   "largos" (una fila por combinacion tratamiento-visita) y se reorganizan
##   a formato "ancho" (una columna por brazo), para que se vea como una
##   tabla real.

lsm_wide <- results$lsm %>%
  mutate(stat = paste0(fmt_num(LSM_CHG, 2), " (", fmt_num(LSM_CHG_SE, 3), ")")) %>%
  select(AVISIT, TRT01P, stat) %>%
  pivot_wider(names_from = TRT01P, values_from = stat) %>%
  mutate(row_label = "  LSM Change (SE)") %>%
  select(AVISIT, row_label, all_of(trt_levels))

pval_wide <- results$pval %>%
  mutate(
    TRT01P = factor(TRT01P, levels = trt_levels),
    stat   = fmt_pval(p.value, 4)
  ) %>%
  select(AVISIT, TRT01P, stat) %>%
  pivot_wider(names_from = TRT01P, values_from = stat) %>%
  mutate(
    Placebo = "--",           # EXPLICACION: el brazo de referencia no tiene
                              # p-valor contra si mismo, se muestra "--"
    row_label = "  p-value vs. Placebo"
  ) %>%
  select(AVISIT, row_label, all_of(trt_levels))

# EXPLICACION: fila con el numero de pacientes (n) que contribuyeron datos
#   (CHG no vacio) en cada visita y brazo -- util para ver si hubo perdida
#   de seguimiento (dropout) entre visitas.
n_wide <- adbds %>%
  filter(!is.na(CHG)) %>%
  count(AVISIT, TRT01P, .drop = FALSE, name = "n") %>%
  pivot_wider(names_from = TRT01P, values_from = n) %>%
  mutate(row_label = "  n") %>%
  select(AVISIT, row_label, all_of(trt_levels))

# EXPLICACION: para cada visita (Week 4, 8, 12), se arma un bloque con:
#   fila de titulo de la visita, luego n, luego LSM (SE), luego el p-valor.
#   map_dfr() recorre las 3 visitas y apila los 3 bloques en el orden
#   correcto.
tbl_body <- purrr::map_dfr(visit_levels, function(v) {
  header_row <- tibble(row_label = v, !!!setNames(rep("", length(trt_levels)), trt_levels))
  bind_rows(
    header_row,
    n_wide    %>% filter(AVISIT == v) %>% select(-AVISIT),
    lsm_wide  %>% filter(AVISIT == v) %>% select(-AVISIT),
    pval_wide %>% filter(AVISIT == v) %>% select(-AVISIT)
  )
})

## ---- 5. Construir el DOCX con officer + flextable ----------------------------
## EXPLICACION: mismo patron de siempre: armar titulo/subtitulo/footnote,
##   crear la flextable, poner en negrita las filas de titulo de visita, y
##   generar el archivo .docx final.

title_text    <- "Table 14.2.1"
subtitle_text <- "Analysis of Change from Baseline by Visit — ANCOVA (LS Means)"
subtitle2     <- "(Efficacy Population)"
footnote_text <- paste(
  "LS Mean, standard error, and p-value derived from an ANCOVA model with change from baseline",
  "as the response and baseline value, visit, treatment, and treatment-by-visit interaction as",
  "explanatory variables (no repeated measures / no covariance structure applied).",
  "p-values are unadjusted, from pairwise comparisons vs. Placebo within each visit."
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

# EXPLICACION: se identifican las filas que son "titulo de visita" (Week 4,
#   Week 8, Week 12) para ponerlas en negrita.
visit_row_idx <- which(tbl_body$row_label %in% visit_levels)

ft <- ft %>%
  align(align = "center", part = "header") %>%
  align(j = 2:4, align = "center", part = "body") %>%
  align(j = 1, align = "left", part = "body") %>%
  bold(i = visit_row_idx, j = 1) %>%
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

out_path <- "lsm_table_14_2_1.docx"
print(doc, target = out_path)

message("TFL table written to: ", normalizePath(out_path))
