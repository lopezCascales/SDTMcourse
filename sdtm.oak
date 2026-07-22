An Electronic Data Capture system (EDC) and Data Standard agnostic solution 
that enables the pharmaceutical programming community to develop Clinical 
Data Interchange Standards Consortium (CDISC) Study Data Tabulation Model (SDTM) datasets in R. 

The reusable algorithms concept in 'sdtm.oak' provides a framework for modular programming and 
can potentially automate the conversion of raw clinical data to SDTM through standardized SDTM specifications. 

SDTM is one of the required standards for data submission to the Food and Drug Administration (FDA) 
in the United States and Pharmaceuticals and Medical Devices Agency (PMDA) in Japan. 
SDTM standards are implemented following the SDTM Implementation Guide as defined by 
CDISC https://www.cdisc.org/standards/foundational/sdtmig.

######################################################################################################
install.packages("sdtm.oak")
# install.packages("remotes")
remotes::install_github("pharmaverse/sdtm.oak")

> library(sdtm.oak)

######################################################################################################

Algorithms & Sub-Algorithms
Core Concept

SDTM mappings are defined as algorithms that transform the collected (eCRF, eDT) source data 
into the target SDTM data model. Mapping algorithms are the backbone of the {sdtm.oak} - SDTM data transformation engine.

Key Points:

    Algorithms can be re-used across multiple SDTM domains.
    Algorithms are pre-specified for data collection standards in MDR (if applicable) to facilitate automation.
    Programming language agnostic - this concept does not rely on a specific programming language for implementation. 
    The {sdtm.oak} team implemented them as R functions.

List of Algorithms

This release of {sdtm.oak} supports the following algorithms: 
assign_no_ct, assign_ct, hardcode_no_ct, hardcode_ct, assign_datetime, condition_add. 
Rest of the algorithms will be developed in the subsequent releases.

The following table provides a brief description of each algorithm.

Algorithm.Name 	
assign_no_ct 	  One-to-one mapping between the raw source and a target SDTM variable that 
                has no controlled terminology restrictions. Just a simple assignment statement. 	
                Example:  MH.MHTERM
                          AE.AETERM

assign_ct 	    One-to-one mapping between the raw source and a target SDTM variable that 
                is subject to controlled terminology restrictions. A simple assign statement and 
                applying controlled terminology. 
                This will be used only if the SDTM variable has an associated controlled terminology. 	
                Example:  VS.VSPOS
                          VS.VSLAT

assign_datetime 	One-to-one mapping between the raw source and a target that involves mapping a Date 
                  or time or datetime component. This mapping algorithm also takes care of handling 
                  unknown dates and converting them into. ISO8601 format. 	
                 Example: MH.MHSTDTC
                          AE.AEENDTC

hardcode_ct 	  Mapping a hardcoded value to a target SDTM variable that is subject to terminology restrictions. 
                This will be used only if the SDTM variable has an associated controlled terminology. 	
                Example:  MH.MHPRESP = ‘Y’
                          VS.VSTEST = ‘Systolic Blood Pressure’
                          VS.VSORRESU = ‘mmHg’

hardcode_no_ct 	Mapping a hardcoded value to a target SDTM variable that has no terminology restrictions. 	
                Example:  FA.FASCAT = ‘COVID-19 PROBABLE CASE’
                          CM.CMTRT = ‘FLUIDS’

condition_add 	Algorithm that is used to filter the source data and/or target domain based on a condition. 
                The mapping will be applied only if the condition is met. The filter can be applied either 
                at the source dataset or at target dataset or both. This algorithm has to be used in conjunction 
                with other algorithms, that is if the condition is met perform the mapping using algorithms 
                like assign_ct, assign_no_ct, hardcode_ct, hardcode_no_ct, assign_datetime. 	
                Example:  If If MDPRIOR == 1 then CM.CMSTRTPT = ‘BEFORE’.
                          VS.VSMETHOD when VSTESTCD = ‘TEMP’
                          If collected value in raw variable DOS is numeric then CM.CMDOSE
                          If collected value in raw variable MOD is different to CMTRT then map to CM.CMMODIFY

ae_aerel 	      Algorithm that is currently unique to AE.AEREL, particularly when more than one drug is used in the study.
                If any collected study drug causalities are ‘Yes’ then AE.AEREL is Y.
                If all collected study drug causalities are ‘NA’ then AE.AEREL is NA.
                If no study drug causalities are ‘Yes’ but there is at least one causality of ‘No’ then AE.AEREL is N.
                Individual study drug causality responses are stored in AERELn in SUPPAE. 	 
                Example:  For AE.AEREL and AERELn in SUPPAE

dataset_level 	Indicates a dataset-level mapping. These mappings will be applied to all SDTM records 
                created from that source. Also called an eCRF-level mappings in eCRF and dataset-level 
                mappings in eDT 	
                Example:  VS = ‘Vital Signs’
                          MH.MHCAT = ‘PROSTATE CANCER HISTORY’

not_submitted 	Instruction that sdtm.oak should not map the collected item to SDTM at all. 

relrec          	Associate two domains based on the variables in each domain and how those are related. 
                  Specifies the name of two domains that are related via RELREC. 	
                  Example: BE record related to BS record via RELREC

multiple_responses 	Consolidate the responses from more than one source variable into one target variable. 
                    Used when multiple responses may be given for a single SDTM column. 
                    sdtm.oak will populate all target variable(s) after determining the number of responses provided. 	
                    Example:  AE.AERELNST/ AERELNSn IN SUPPAE
                              DM.RACE, if only one value is selected.
                              DM.RACE = MULTIPLE, if more than one value is selected.
                              RACEn in SUPPDM where n = 1 to N selected values

split_to_suppqual 	Consolidates the responses from more than one source variable into more than one 
                    target variable (always a suppqual/non-standard variable). There is no ‘parent’ 
                    target variable that is populated with ‘MULTIPLE’. 	
                    Example:  If both Filipino and Samoan are checked, CRACE1 will be ‘FILIPINO’ and CRACE2 will be ‘SAMOAN’.
                              If only Chinese is checked, CRACE1 will be ‘CHINESE’.


Sub-algorithms

{sdtm.oak} supports two levels for defining algorithms. 
For example, there are some SDTM mappings where a certain action has to be taken only when a condition is met. 
In such cases, the primary algorithm checks for the condition, and the sub-algorithm executes the mappings 
when the condition is met.

Currently, sub-algorithms must be provided for this main algorithms.

    condition_add
    dataset_level

The permutation & combination of algorithms & sub-algorithms creates endless possibilities to accommodate 
different types of mappings.    

Some algorithms can be interchangeably used as algorithms and as sub-algorithms as seen below (not an exhaustive list)

remove_dup 	  Sub-algorithm at the domain level that indicates some source records may be removed during 
              the sdtm.oak mapping process if determined to be duplicate records. 	
              Example: Remove duplicates on the Vital signs raw dataset based on subject number

group_by 	    Sub-algorithm used at the domain level to group source records before mapping to SDTM. 
              This is used in the event we need to collapse data collected across multiple rows into 
              one row in SDTM but it is not a simple un-duplication effort. 
              For example, the way infusion study drug administration data requires us to create 1 SDTM record 
              in EC from 1 or more sources records. 
              When there is more than one source record, we need to take the earliest collected infusion 
              start date (for ECSTDTC) and the latest collected infusion end date within an eCRF instance. 	
              Example: EC = ‘Exposure as Collected’

merge_datasets 	To indicate a join condition with a secondary source or multiple sources. 
                Merges are expressed at the domain level only (not at data point or variable level). 
                This is a sub-algorithm and can only be used with algorithm DATASET_LEVEL. 	
                Example: Merge AE raw dataset with SAE based on Subject number.


###############################################################################################################

Creating an Interventions SDTM domain

creating an Interventions SDTM domain using the sdtm.oak package. 

Raw data
Raw datasets can be exported from the EDC systems in the format they are collected. 
The example used provides a raw dataset for Concomitant medications, where the collected data 
is represented as columns for each subject. 
For example, the Medication Name(MDRAW), Medication Start Date (MDBDR), Start Time (MDBTM), 
End Date (MDEDR), End time (MDETM), etc. are represented as columns.

This format is commonly used in most EDC systems.
In {sdtm.oak} we process one raw dataset at a time. Similar raw datasets 
(example Concomitant medications (OID - cm_raw), 
Targeted Concomitant Medications (OID - cm_t_raw)) 
can be stacked together before processing.

Read in data

Read all the raw datasets into the environment. 
In this example, the raw dataset name is cm_raw. 
Users can read it from the package using the below code:

cm_raw <- read.csv(system.file("raw_data/cm_raw_data.csv",
  package = "sdtm.oak"
))

> head(cm_raw)
  PATNUM   SUBJSTAT    SITENM                INSTANCE INSTRN FOLDER
1    375 Randomized TEST SITE Concomitant Medications      0     MD
2    375 Randomized TEST SITE Concomitant Medications      0     MD
3    376 Randomized TEST SITE Concomitant Medications      0     MD
4    377 Randomized TEST SITE Concomitant Medications      0     MD
5    377 Randomized TEST SITE Concomitant Medications      0     MD
6    377 Randomized TEST SITE Concomitant Medications      0     MD
                  FOLDERL FOLDERSQ FORM                   FORML DATAPGID
1 Concomitant Medications       15  MD1 Concomitant Medications 56379253
2 Concomitant Medications       15  MD1 Concomitant Medications 56379253
3 Concomitant Medications       15  MD1 Concomitant Medications 56407664
4 Concomitant Medications       15  MD1 Concomitant Medications 56408736
5 Concomitant Medications       15  MD1 Concomitant Medications 56408736
6 Concomitant Medications       15  MD1 Concomitant Medications 56408736
  PGREPNUM RECORDDT  RECORDID RECPOS RECSTAT MDNUM MDNUM_RAW MDREC
1        0       NA 111885785      1       N     1         1    No
2        0       NA 111969387      2       N     2         2    No
3        0       NA 111939965      1       N     1         1    No
4        0       NA 111942855      1       N     1         1    No
5        0       NA 129972536      2       N     2         2    No
6        0       NA 129972541      3       N     3         3    No
                MDRAW     MDIND       MDBDR MDBDTU MDBTM MDBTMU MDPRIOR
1        BABY ASPIRIN                            1            1       1
2         CORTISPORIN    NAUSEA   15-Sep-20      0            1       0
3             ASPIRIN    ANEMIA   17-Feb-21      0  8:00      0       0
4 DIPHENHYDRAMINE HCL    NAUSEA    4-Oct-20      0  9:00      0       0
5          PARCETEMOL   PYREXIA   20-Jan-20      0 10:00      0       0
6            VOMIKIND VOMITINGS UN UNK 2019      1            1       0
        MDEDR   MDEDT MDETM MDETMU MDONG DOS   DOSU  DOSUV  MDFORM     MDRTE
1                                0     1  10     mg     MG  Tablet PO (Oral)
2                                0     1  50      g      G    Pill PO (Oral)
3   17-Feb-21 2/17/21            0     0  NA                                
4                                0     1  50     mg     MG Capsule PO (Oral)
5   20-Jan-20 1/20/20 10:00      0     0  NA     mg     MG Capsule PO (Oral)
6 UN UNK 2019 6/15/19            1     0  NA Tablet TABLET         PO (Oral)
              MDFRQ MDPROPH    TERMID SRCLN RAVRFID                      MODIFY
1    QD (Every Day)       0 109576058    20 5652739                BABY ASPIRIN
2                         0 105820348    28 5533807 CORTISPORIN (UNITED STATES)
3                         0  80619660     8 4297014                     ASPIRIN
4 BID (Twice a Day)       0  79751919     3 4240092         DIPHENHYDRAMINE HCL
5 BID (Twice a Day)       1 129972536     2      NA                            
6   PRN (As Needed)       1 129972541     3      NA                            
                                              CMDRG     CMDRGCD
1                                      BABY ASPIRIN     2701701
2 CORTICOSTEROIDS AND ANTIINFECTIVES IN COMBINATION 90104001001
3                    ASPIRIN [ACETYLSALICYLIC ACID]     2701004
4                               DIPHENHYDRAMINE HCL      402246
5                                                            NA
6                                                            NA
                                            CMDECOD      CMPNCD SPLIT OMIT
1                              ACETYLSALICYLIC ACID     2701001    NA   NA
2 CORTICOSTEROIDS AND ANTIINFECTIVES IN COMBINATION 90104001001    NA   NA
3                              ACETYLSALICYLIC ACID     2701001    NA   NA
4                     DIPHENHYDRAMINE HYDROCHLORIDE      402001    NA   NA
5                                                            NA    NA   NA
6                                                            NA    NA   NA
   ACTTYP                    ACTTEXT                          CMDICT
1                                    WHODRUG GLOBAL B3 MARCH 1, 2021
2 COUNTRY APPLY SITE COUNTRY TO TERM WHODRUG GLOBAL B3 MARCH 1, 2021
3                                    WHODRUG GLOBAL B3 MARCH 1, 2021
4                                    WHODRUG GLOBAL B3 MARCH 1, 2021
5                                                                   
6                                                                   
                                             CMCLAS CMCLASCD
1             OTHER AGENTS FOR LOCAL ORAL TREATMENT    A01AD
2 CORTICOSTEROIDS AND ANTIINFECTIVES IN COMBINATION    S03CA
3             OTHER AGENTS FOR LOCAL ORAL TREATMENT    A01AD
4                                 AMINOALKYL ETHERS    R06AA
5                                                           
6                                                           
                                             CMATC4 CMATC4CD
1             OTHER AGENTS FOR LOCAL ORAL TREATMENT    A01AD
2 CORTICOSTEROIDS AND ANTIINFECTIVES IN COMBINATION    S03CA
3             OTHER AGENTS FOR LOCAL ORAL TREATMENT    A01AD
4                                 AMINOALKYL ETHERS    R06AA
5                                                           
6                                                           
                                             CMATC3 CMATC3CD
1                       STOMATOLOGICAL PREPARATIONS     A01A
2 CORTICOSTEROIDS AND ANTIINFECTIVES IN COMBINATION     S03C
3                       STOMATOLOGICAL PREPARATIONS     A01A
4                   ANTIHISTAMINES FOR SYSTEMIC USE     R06A
5                                                           
6                                                           
                                        CMATC2 CMATC2CD
1                  STOMATOLOGICAL PREPARATIONS      A01
2 OPHTHALMOLOGICAL AND OTOLOGICAL PREPARATIONS      S03
3                  STOMATOLOGICAL PREPARATIONS      A01
4              ANTIHISTAMINES FOR SYSTEMIC USE      R06
5                                                      
6                                                      
                           CMATC1 CMATC1CD CLASSNUM
1 ALIMENTARY TRACT AND METABOLISM        A        1
2                  SENSORY ORGANS        S        1
3 ALIMENTARY TRACT AND METABOLISM        A        1
4              RESPIRATORY SYSTEM        R        1
5                                                NA
6                                                NA

######################################################################################################

Create oak_id_vars

The oak_id_vars is a crucial link between the raw datasets and the mapped SDTM domain. 
As the user derives each SDTM variable, it is merged with the corresponding topic variable using oak_id_vars. 
In {sdtm.oak}, the variables oak_id, raw_source, and patient_number are considered as oak_id_vars. 
These three variables must be added to all raw datasets. They are used in multiple places in the programming.

oak_id:- Type: numeric- Value: equal to the raw dataframe row number.

raw_source:- Type: Character- Value: equal to the raw dataset (eCRF) name or eDT dataset name.

patient_number:- Type: numeric- Value: equal to the subject number in CRF or NonCRF data source.

library(dplyr)
cm_raw <- cm_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "cm_raw"
  )
colnames(cm_raw)
 [1] "oak_id"         "raw_source"     "patient_number" "PATNUM"        
 [5] "SUBJSTAT"       "SITENM"         "INSTANCE"       "INSTRN"        
 [9] "FOLDER"         "FOLDERL"        "FOLDERSQ"       "FORM"          
[13] "FORML"          "DATAPGID"       "PGREPNUM"       "RECORDDT"      
[17] "RECORDID"       "RECPOS"         "RECSTAT"        "MDNUM"         
[21] "MDNUM_RAW"      "MDREC"          "MDRAW"          "MDIND"         
[25] "MDBDR"          "MDBDTU"         "MDBTM"          "MDBTMU"        
[29] "MDPRIOR"        "MDEDR"          "MDEDT"          "MDETM"         
[33] "MDETMU"         "MDONG"          "DOS"            "DOSU"          
[37] "DOSUV"          "MDFORM"         "MDRTE"          "MDFRQ"         
[41] "MDPROPH"        "TERMID"         "SRCLN"          "RAVRFID"       
[45] "MODIFY"         "CMDRG"          "CMDRGCD"        "CMDECOD"       
[49] "CMPNCD"         "SPLIT"          "OMIT"           "ACTTYP"        
[53] "ACTTEXT"        "CMDICT"         "CMCLAS"         "CMCLASCD"      
[57] "CMATC4"         "CMATC4CD"       "CMATC3"         "CMATC3CD"      
[61] "CMATC2"         "CMATC2CD"       "CMATC1"         "CMATC1CD"      
[65] "CLASSNUM"      

######################################################################################################

Read in the DM domain

dm <- read.csv(system.file("raw_data/dm.csv",
  package = "sdtm.oak"
))
head(dm)
     STUDYID DOMAIN        USUBJID         SUBJID          RFSTDTC
1 test_study     DM test_study-375 test_study-375 1999-04-14T08:36
2 test_study     DM test_study-376 test_study-376       2001-03-21
3 test_study     DM test_study-377 test_study-377       1999-03-14
4 test_study     DM test_study-378 test_study-378 2003-02-06T06:33
5 test_study     DM test_study-379 test_study-379 2003-02-06T06:33
           RFENDTC         RFXSTDTC         RFXENDTC    RFICDTC   RFPENDTC
1       2013-01-21 2023-04-14T08:36 2021-01-11T07:50 2007-01-15 2020-04-02
2       2007-05-21       2020-03-21 2017-09-14T18:49       <NA> 2011-12-18
3       2021-05-05       2020-03-14 2013-08-23T12:37 2015-10-07 2021-05-05
4 2021-04-24T09:06 2021-02-06T06:33 2021-04-24T09:06 2018-10-20 2017-04-11
5 2021-04-24T09:06 2022-02-06T06:33 2021-04-24T09:06 2018-10-20 2017-04-11
      DTHDTC DTHFL SITEID INVID     INVNAM          BRTHDTC AGE  AGEU  SEX
1 2020-04-02     Y 111111 90009 Dr doctor9             <NA>  NA  <NA>    F
2 2011-12-18  <NA> 111111 90009 Dr doctor9 1981-02-26T18:07  42 YEARS    M
3 2019-06-29  <NA> 111111 90009 Dr doctor9 1968-03-19T04:36  56 YEARS <NA>
4 2017-04-11  <NA> 111111 90009 Dr doctor9       1979-09-24  45 YEARS    M
5 2017-04-11     Y 111111 90009 Dr doctor9       1963-09-24  61 YEARS    M
                       RACE                 ETHNIC ARMCD ARM ACTARMCD ACTARM
1                  MULTIPLE                   <NA>    NA  NA       NA     NA
2                  MULTIPLE NOT HISPANIC OR LATINO    NA  NA       NA     NA
3                  MULTIPLE           NOT REPORTED    NA  NA       NA     NA
4 BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO    NA  NA       NA     NA
5 BLACK OR AFRICAN AMERICAN     HISPANIC OR LATINO    NA  NA       NA     NA
  COUNTRY DMDTC DMDY                                     RACE1
1      US    NA   NA NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER
2      US    NA   NA                 BLACK OR AFRICAN AMERICAN
3      US    NA   NA                                     ASIAN
4      US    NA   NA                                      <NA>
5      US    NA   NA                                      <NA>
                             RACE2   RACE3
1                            WHITE    <NA>
2 AMERICAN INDIAN OR ALASKA NATIVE UNKNOWN
3 AMERICAN INDIAN OR ALASKA NATIVE UNKNOWN
4                             <NA>    <NA>
5                             <NA>    <NA>

 colnames(dm)
 [1] "STUDYID"  "DOMAIN"   "USUBJID"  "SUBJID"   "RFSTDTC"  "RFENDTC" 
 [7] "RFXSTDTC" "RFXENDTC" "RFICDTC"  "RFPENDTC" "DTHDTC"   "DTHFL"   
[13] "SITEID"   "INVID"    "INVNAM"   "BRTHDTC"  "AGE"      "AGEU"    
[19] "SEX"      "RACE"     "ETHNIC"   "ARMCD"    "ARM"      "ACTARMCD"
[25] "ACTARM"   "COUNTRY"  "DMDTC"    "DMDY"     "RACE1"    "RACE2"   
[31] "RACE3"  
#######################################################################################################

Read in CT

Controlled Terminology (CT) is part of the SDTM specification and it is prepared by the user. 
In this example, the study controlled terminology name is sdtm_ct.csv. 
Users can read it from the package using the below code:

study_ct <- read.csv(system.file("raw_data/sdtm_ct.csv",
  package = "sdtm.oak"
))

colnames(study_ct)
[1] "codelist_code"       "term_code"           "term_value"         
[4] "collected_value"     "term_preferred_term" "term_synonyms"      
> head(study_ct)
  codelist_code term_code term_value collected_value    term_preferred_term
1        C66726    C25158    CAPSULE         Capsule    Capsule Dosage Form
2        C66726    C25394       PILL            Pill       Pill Dosage Form
3        C66726    C29167     LOTION          Lotion     Lotion Dosage Form
4        C66726    C42887    AEROSOL         Aerosol    Aerosol Dosage Form
5        C66726    C42944   INHALANT        Inhalant   Inhalant Dosage Form
6        C66726    C42946  INJECTION       Injection Injectable Dosage Form
  term_synonyms
1           cap
2              
3              
4           aer
5              
6  
######################################################################################################


Map Topic Variable

The topic variable is mapped as a first step in the mapping process. 
It is the primary variable in the SDTM domain. The rest of the variables add further definition to the topic variable. 
In this example, the topic variable is CMTRT. 
It is mapped from the raw dataset column MDRAW. T
he mapping logic is Map the collected value in the cm_raw dataset MDRAW variable to CM.CMTRT.

This mapping does not involve any controlled terminology. 
The assign_no_ct function is used for mapping. Once the topic variable is mapped, 
the Qualifier, Identifier, and Timing variables can be mapped.

cm <-
  # Map topic variable
  assign_no_ct(
    raw_dat = cm_raw,
    raw_var = "MDRAW",
    tgt_var = "CMTRT"
  )
  
cm
# A tibble: 14 × 4
   oak_id raw_source patient_number CMTRT                        
    <int> <chr>               <int> <chr>                        
 1      1 cm_raw                375 BABY ASPIRIN                 
 2      2 cm_raw                375 CORTISPORIN                  
 3      3 cm_raw                376 ASPIRIN                      
 4      4 cm_raw                377 DIPHENHYDRAMINE HCL          
 5      5 cm_raw                377 PARCETEMOL                   
 6      6 cm_raw                377 VOMIKIND                     
 7      7 cm_raw                377 ZENFLOX OZ                   
 8      8 cm_raw                378 AMITRYPTYLINE                
 9      9 cm_raw                378 BENADRYL                     
10     10 cm_raw                378 DIPHENHYDRAMINE HYDROCHLORIDE
11     11 cm_raw                378 TETRACYCLINE                 
12     12 cm_raw                379 BENADRYL                     
13     13 cm_raw                379 SOMINEX                      
14     14 cm_raw                379 ZQUILL                       
> colnames(cm)
[1] "oak_id"         "raw_source"     "patient_number" "CMTRT"          


######################################################################################################

Map Rest of the Variables

The Qualifiers, Identifiers, and Timing Variables can be mapped in any order. 
In this example, we will map each variable one by one to demonstrate different mapping algorithms.
assign_no_ct

The mapping logic for CMGRPID is Map the collected value in the cm_raw dataset MDNUM variable to CM.CMGRPID.

cm <- cm %>%
  # Map CMGRPID
  assign_no_ct(
    raw_dat = cm_raw,
    raw_var = "MDNUM",
    tgt_var = "CMGRPID",
    id_vars = oak_id_vars()
  )

  > cm
# A tibble: 14 × 5
   oak_id raw_source patient_number CMTRT                         CMGRPID
    <int> <chr>               <int> <chr>                           <int>
 1      1 cm_raw                375 BABY ASPIRIN                        1
 2      2 cm_raw                375 CORTISPORIN                         2
 3      3 cm_raw                376 ASPIRIN                             1
 4      4 cm_raw                377 DIPHENHYDRAMINE HCL                 1
 5      5 cm_raw                377 PARCETEMOL                          2
 6      6 cm_raw                377 VOMIKIND                            3
 7      7 cm_raw                377 ZENFLOX OZ                          5
 8      8 cm_raw                378 AMITRYPTYLINE                       4
 9      9 cm_raw                378 BENADRYL                            1
10     10 cm_raw                378 DIPHENHYDRAMINE HYDROCHLORIDE       2
11     11 cm_raw                378 TETRACYCLINE                        3
12     12 cm_raw                379 BENADRYL                            1
13     13 cm_raw                379 SOMINEX                             2
14     14 cm_raw                379 ZQUILL                              3
> colnames(cm)
[1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
[5] "CMGRPID" 
######################################################################################################

The CMGRPID is added to the corresponding CMTRT based on the ‘oak_id_vars’. 
When calling the function, the parameter ‘id_vars = oak_id_vars()’ matches the raw dataset 
‘oak_id_vars’ to the ‘oak_id_vars’ in the cm domain created in the previous step. 
It’s important to note that the ‘oak_id_vars’ can be extended to include user-defined variables. 
But in most cases, the three variables should suffice.
assign_ct

The mapping logic for CMDOSU is Map the collected value in the cm_raw dataset DOSU variable to CM.CMDOSU. 
The controlled terminology is used to map the collected value to the standard value. 
assign_ct is the right algorithm to perform this mapping.

cm <- cm %>%
  # Map qualifier CMDOSU
  assign_ct(
    raw_dat = cm_raw,
    raw_var = "DOSU",
    tgt_var = "CMDOSU",
    ct_spec = study_ct,
    ct_clst = "C71620",
    id_vars = oak_id_vars()
  )

  cm
# A tibble: 14 × 6
   oak_id raw_source patient_number CMTRT                         CMGRPID CMDOSU
    <int> <chr>               <int> <chr>                           <int> <chr> 
 1      1 cm_raw                375 BABY ASPIRIN                        1 "mg"  
 2      2 cm_raw                375 CORTISPORIN                         2 "g"   
 3      3 cm_raw                376 ASPIRIN                             1 ""    
 4      4 cm_raw                377 DIPHENHYDRAMINE HCL                 1 "mg"  
 5      5 cm_raw                377 PARCETEMOL                          2 "mg"  
 6      6 cm_raw                377 VOMIKIND                            3 "TABL…
 7      7 cm_raw                377 ZENFLOX OZ                          5 "mL"  
 8      8 cm_raw                378 AMITRYPTYLINE                       4 "g"   
 9      9 cm_raw                378 BENADRYL                            1 "mg"  
10     10 cm_raw                378 DIPHENHYDRAMINE HYDROCHLORIDE       2 "CAPS…
11     11 cm_raw                378 TETRACYCLINE                        3 "mg"  
12     12 cm_raw                379 BENADRYL                            1 "IU"  
13     13 cm_raw                379 SOMINEX                             2 "mL"  
14     14 cm_raw                379 ZQUILL                              3 "%"   
> colnames(cm)
[1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
[5] "CMGRPID"        "CMDOSU"
######################################################################################
assign_datetime

The mapping logic for CMSTDTC is Map the collected value in the cm_raw dataset 
MDBDR (start date) variable and MDBTM (start time) to CM.CMSTDTC. 
The collected date value is in the format ‘dd mmm yyyy’. 
The collected time value is in ‘H”M’ format. 
The assign_datetime function is used to map the collected value in ISO8601 format.

cm <- cm %>%
  # Map CMSTDTC. This function calls create_iso8601
  assign_datetime(
    raw_dat = cm_raw,
    raw_var = c("MDBDR", "MDBTM"),
    tgt_var = "CMSTDTC",
    raw_fmt = c(list(c("d-m-y", "dd mmm yyyy")), "H:M"),
    raw_unk = c("UN", "UNK"),
    id_vars = oak_id_vars()
  )

  > cm
# A tibble: 14 × 7
   oak_id raw_source patient_number CMTRT                 CMGRPID CMDOSU CMSTDTC
    <int> <chr>               <int> <chr>                   <int> <chr>  <iso86>
 1      1 cm_raw                375 BABY ASPIRIN                1 "mg"   NA    …
 2      2 cm_raw                375 CORTISPORIN                 2 "g"    2020-0…
 3      3 cm_raw                376 ASPIRIN                     1 ""     2021-0…
 4      4 cm_raw                377 DIPHENHYDRAMINE HCL         1 "mg"   2020-1…
 5      5 cm_raw                377 PARCETEMOL                  2 "mg"   2020-0…
 6      6 cm_raw                377 VOMIKIND                    3 "TABL… 2019  …
 7      7 cm_raw                377 ZENFLOX OZ                  5 "mL"   2019--…
 8      8 cm_raw                378 AMITRYPTYLINE               4 "g"    2020  …
 9      9 cm_raw                378 BENADRYL                    1 "mg"   2020-0…
10     10 cm_raw                378 DIPHENHYDRAMINE HYDR…       2 "CAPS… 2020-0…
11     11 cm_raw                378 TETRACYCLINE                3 "mg"   2020-0…
12     12 cm_raw                379 BENADRYL                    1 "IU"   2020--…
13     13 cm_raw                379 SOMINEX                     2 "mL"   NA    …
14     14 cm_raw                379 ZQUILL                      3 "%"    NA    …
> colnames(cm)
[1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
[5] "CMGRPID"        "CMDOSU"         "CMSTDTC"      
########################################################################################

hardcode_ct and condition_add

The mapping logic for CMSTRTPT is as follows: 
If the collected value in the raw variable MDPRIOR and raw dataset cm_raw equals to 1, 
then CM.CMSTRTPT == 'BEFORE'. The hardcode_ct function is used to map the 
CMSTRTPT as it involves hardcoding a specific value to an SDTM variable with controlled terminology. 
The condition_add function filters the raw dataset based on a particular condition, 
and the hardcode_ct function performs the mapping.

When these two functions are used together, the condition_add function first filters the 
raw dataset based on the specified condition. Next, the filtered dataset is then passed 
to the hardcode_ct function to assign the appropriate value. This example illustrates 
how the hardcode_ct algorithm functions as a sub-algorithm to condition_add.

cm <- cm %>%
  # Map qualifier CMSTRTPT  Annotation text is If MDPRIOR == 1 then CM.CMSTRTPT = 'BEFORE'
  hardcode_ct(
    raw_dat = condition_add(cm_raw, MDPRIOR == "1"),
    raw_var = "MDPRIOR",
    tgt_var = "CMSTRTPT",
    tgt_val = "BEFORE",
    ct_spec = study_ct,
    ct_clst = "C66728",
    id_vars = oak_id_vars()
  )
cm
# A tibble: 14 × 8
   oak_id raw_source patient_number CMTRT        CMGRPID CMDOSU CMSTDTC CMSTRTPT
    <int> <chr>               <int> <chr>          <int> <chr>  <iso86> <chr>   
 1      1 cm_raw                375 BABY ASPIRIN       1 "mg"   NA    … BEFORE  
 2      2 cm_raw                375 CORTISPORIN        2 "g"    2020-0… NA      
 3      3 cm_raw                376 ASPIRIN            1 ""     2021-0… NA      
 4      4 cm_raw                377 DIPHENHYDRA…       1 "mg"   2020-1… NA      
 5      5 cm_raw                377 PARCETEMOL         2 "mg"   2020-0… NA      
 6      6 cm_raw                377 VOMIKIND           3 "TABL… 2019  … NA      
 7      7 cm_raw                377 ZENFLOX OZ         5 "mL"   2019--… NA      
 8      8 cm_raw                378 AMITRYPTYLI…       4 "g"    2020  … BEFORE  
 9      9 cm_raw                378 BENADRYL           1 "mg"   2020-0… NA      
10     10 cm_raw                378 DIPHENHYDRA…       2 "CAPS… 2020-0… BEFORE  
11     11 cm_raw                378 TETRACYCLINE       3 "mg"   2020-0… BEFORE  
12     12 cm_raw                379 BENADRYL           1 "IU"   2020--… NA      
13     13 cm_raw                379 SOMINEX            2 "mL"   NA    … NA      
14     14 cm_raw                379 ZQUILL             3 "%"    NA    … NA      
> colnames(cm)
[1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
[5] "CMGRPID"        "CMDOSU"         "CMSTDTC"        "CMSTRTPT"     

The condition_add function adds additional metadata to the records in the raw dataset 
that meets the condition. Refer to the function documentation for more details. 
hardcode_ct function uses the additional metadata to find the records that meet the criteria and map them accordingly.

########################################################################################
hardcode_no_ct and condition_add

The mapping logic for CMSTTPT is as follows: 
If the collected value in the raw variable MDPRIOR and raw dataset cm_raw equals to 1,
then CM.CMSTTPT == 'SCREENING'. The hardcode_no_ct function is used to map the 
CMSTTPT as it involves hardcoding a specific value to an SDTM variable without controlled terminology. 
The condition_add function filters the raw dataset based on a particular condition, and 
the hardcode_no_ct function performs the mapping.

cm <- cm %>%
  # Map qualifier CMSTTPT  Annotation text is If MDPRIOR == 1 then CM.CMSTTPT = 'SCREENING'
  hardcode_no_ct(
    raw_dat = condition_add(cm_raw, MDPRIOR == "1"),
    raw_var = "MDPRIOR",
    tgt_var = "CMSTTPT",
    tgt_val = "SCREENING",
    id_vars = oak_id_vars()
  )

   cm
# A tibble: 14 × 9
   oak_id raw_source patient_number CMTRT        CMGRPID CMDOSU CMSTDTC CMSTRTPT
    <int> <chr>               <int> <chr>          <int> <chr>  <iso86> <chr>   
 1      1 cm_raw                375 BABY ASPIRIN       1 "mg"   NA    … BEFORE  
 2      2 cm_raw                375 CORTISPORIN        2 "g"    2020-0… NA      
 3      3 cm_raw                376 ASPIRIN            1 ""     2021-0… NA      
 4      4 cm_raw                377 DIPHENHYDRA…       1 "mg"   2020-1… NA      
 5      5 cm_raw                377 PARCETEMOL         2 "mg"   2020-0… NA      
 6      6 cm_raw                377 VOMIKIND           3 "TABL… 2019  … NA      
 7      7 cm_raw                377 ZENFLOX OZ         5 "mL"   2019--… NA      
 8      8 cm_raw                378 AMITRYPTYLI…       4 "g"    2020  … BEFORE  
 9      9 cm_raw                378 BENADRYL           1 "mg"   2020-0… NA      
10     10 cm_raw                378 DIPHENHYDRA…       2 "CAPS… 2020-0… BEFORE  
11     11 cm_raw                378 TETRACYCLINE       3 "mg"   2020-0… BEFORE  
12     12 cm_raw                379 BENADRYL           1 "IU"   2020--… NA      
13     13 cm_raw                379 SOMINEX            2 "mL"   NA    … NA      
14     14 cm_raw                379 ZQUILL             3 "%"    NA    … NA      
# ℹ 1 more variable: CMSTTPT <chr>
> colnames(cm)
[1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
[5] "CMGRPID"        "CMDOSU"         "CMSTDTC"        "CMSTRTPT"      
[9] "CMSTTPT"
####################################################################################

condition_add involving target domain

In the mapping for CMSTRTPT and CMSTTTPT, the condition_add function is used in the raw dataset. 
In this mapping, we can explore how to use condition_add to add a filter condition based on the target SDTM variable.

The mapping logic for CMDOSFRQ is If CMTRT is not null, then map the collected value in raw dataset 
cm_raw and raw variable MDFRQ to CMDOSFRQ. This may or may not represent a valid SDTM mapping in an actual study,
but it can be used as an example.

In this mapping, the condition_add function filters the cm domain created in the previous step and adds metadata 
to the records where it meets the condition. The assign_ct function uses the additional metadata to find 
the records that meet the criteria and map them accordingly.

cm <- cm %>%
  # Map qualifier CMDOSFRQ  Annotation text is If CMTRT is not null then map
  # the collected value in raw dataset cm_raw and raw variable MDFRQ to CMDOSFRQ
  {
    assign_ct(
      raw_dat = cm_raw,
      raw_var = "MDFRQ",
      tgt_dat =  condition_add(., !is.na(CMTRT)),
      tgt_var = "CMDOSFRQ",
      ct_spec = study_ct,
      ct_clst = "C66728",
      id_vars = oak_id_vars()
    )
  }
#> ℹ These terms could not be mapped per the controlled terminology: "QD (Every Day)", 
#"BID (Twice a Day)", "PRN (As Needed)", " ", and "Q2H (Every 2 Hours)".
> cm
# A tibble: 14 × 10
   oak_id raw_source patient_number CMTRT        CMGRPID CMDOSU CMSTDTC CMSTRTPT
    <int> <chr>               <int> <chr>          <int> <chr>  <iso86> <chr>   
 1      1 cm_raw                375 BABY ASPIRIN       1 "mg"   NA    … BEFORE  
 2      2 cm_raw                375 CORTISPORIN        2 "g"    2020-0… NA      
 3      3 cm_raw                376 ASPIRIN            1 ""     2021-0… NA      
 4      4 cm_raw                377 DIPHENHYDRA…       1 "mg"   2020-1… NA      
 5      5 cm_raw                377 PARCETEMOL         2 "mg"   2020-0… NA      
 6      6 cm_raw                377 VOMIKIND           3 "TABL… 2019  … NA      
 7      7 cm_raw                377 ZENFLOX OZ         5 "mL"   2019--… NA      
 8      8 cm_raw                378 AMITRYPTYLI…       4 "g"    2020  … BEFORE  
 9      9 cm_raw                378 BENADRYL           1 "mg"   2020-0… NA      
10     10 cm_raw                378 DIPHENHYDRA…       2 "CAPS… 2020-0… BEFORE  
11     11 cm_raw                378 TETRACYCLINE       3 "mg"   2020-0… BEFORE  
12     12 cm_raw                379 BENADRYL           1 "IU"   2020--… NA      
13     13 cm_raw                379 SOMINEX            2 "mL"   NA    … NA      
14     14 cm_raw                379 ZQUILL             3 "%"    NA    … NA      
# ℹ 2 more variables: CMSTTPT <chr>, CMDOSFRQ <chr>
> colnames(cm)
 [1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
 [5] "CMGRPID"        "CMDOSU"         "CMSTDTC"        "CMSTRTPT"      
 [9] "CMSTTPT"        "CMDOSFRQ"  

Remember to use additional curly braces in the function call when using the 
condition_add function on the target dataset. This is necessary because the 
input target dataset is represented as a . and is passed on from the previous step 
using the {magrittr} pipe operator. Currently, there is a limitation when using a 
nested function call with . to reference one of the input parameters, and this recommended approach will overcome that.

The placeholder . is for use with {magrittr} pipe %>% operator. 
We encourage using . and {magrittr} pipe %>% operator when using {sdtm.oak} functions.

Another way to achieve the same outcome is by moving the ‘condition_by’ call 
up one level, as illustrated below: it is not required to use the 
{magrittr} pipe %>% or curly braces in this case.

cm <- cm %>%
  condition_add(!is.na(CMTRT)) %>%
  assign_ct(
    raw_dat = cm_raw,
    raw_var = "DOSU",
    tgt_var = "CMDOSU",
    ct_spec = study_ct,
    ct_clst = "C71620",
    id_vars = oak_id_vars()
  )

  > cm
# A tibble: 14 × 10
   oak_id raw_source patient_number CMTRT       CMGRPID CMSTDTC CMSTRTPT CMSTTPT
    <int> <chr>               <int> <chr>         <int> <iso86> <chr>    <chr>  
 1      1 cm_raw                375 BABY ASPIR…       1 NA    … BEFORE   SCREEN…
 2      2 cm_raw                375 CORTISPORIN       2 2020-0… NA       NA     
 3      3 cm_raw                376 ASPIRIN           1 2021-0… NA       NA     
 4      4 cm_raw                377 DIPHENHYDR…       1 2020-1… NA       NA     
 5      5 cm_raw                377 PARCETEMOL        2 2020-0… NA       NA     
 6      6 cm_raw                377 VOMIKIND          3 2019  … NA       NA     
 7      7 cm_raw                377 ZENFLOX OZ        5 2019--… NA       NA     
 8      8 cm_raw                378 AMITRYPTYL…       4 2020  … BEFORE   SCREEN…
 9      9 cm_raw                378 BENADRYL          1 2020-0… NA       NA     
10     10 cm_raw                378 DIPHENHYDR…       2 2020-0… BEFORE   SCREEN…
11     11 cm_raw                378 TETRACYCLI…       3 2020-0… BEFORE   SCREEN…
12     12 cm_raw                379 BENADRYL          1 2020--… NA       NA     
13     13 cm_raw                379 SOMINEX           2 NA    … NA       NA     
14     14 cm_raw                379 ZQUILL            3 NA    … NA       NA     
# ℹ 2 more variables: CMDOSFRQ <chr>, CMDOSU <chr>
> colnames(cm)
 [1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
 [5] "CMGRPID"        "CMSTDTC"        "CMSTRTPT"       "CMSTTPT"       
 [9] "CMDOSFRQ"       "CMDOSU"
 
####################################################################################

condition_add involving raw dataset and target domain

In this mapping, we can explore how to use condition_add to add a filter condition 
based on the target SDTM variable.

The mapping logic for CMMODIFY is If collected value in MODIFY in cm_raw 
is different to CM.CMTRT then assign the collected value to CMMODIFY in CM domain (CM.CMMODIFY). 
The assign_no_ct function is used to map the CMMODIFY as it involves mapping the collected 
value to the SDTM variable without controlled terminology. The condition_add function filters 
the raw dataset & target dataset based on a particular condition, and the assign_no_ct function performs the mapping.

cm <- cm %>%
  # Map CMMODIFY  Annotation text  If collected value in MODIFY in cm_raw is
  # different to CM.CMTRT then assign the collected value to CMMODIFY in
  # CM domain (CM.CMMODIFY)
  {
    assign_no_ct(
      raw_dat = cm_raw,
      raw_var = "MODIFY",
      tgt_dat = condition_add(., MODIFY != CMTRT, .dat2 = cm_raw),
      tgt_var = "CMMODIFY",
      id_vars = oak_id_vars()
    )
  }

> cm
# A tibble: 14 × 11
   oak_id raw_source patient_number CMTRT       CMGRPID CMSTDTC CMSTRTPT CMSTTPT
    <int> <chr>               <int> <chr>         <int> <iso86> <chr>    <chr>  
 1      1 cm_raw                375 BABY ASPIR…       1 NA    … BEFORE   SCREEN…
 2      2 cm_raw                375 CORTISPORIN       2 2020-0… NA       NA     
 3      3 cm_raw                376 ASPIRIN           1 2021-0… NA       NA     
 4      4 cm_raw                377 DIPHENHYDR…       1 2020-1… NA       NA     
 5      5 cm_raw                377 PARCETEMOL        2 2020-0… NA       NA     
 6      6 cm_raw                377 VOMIKIND          3 2019  … NA       NA     
 7      7 cm_raw                377 ZENFLOX OZ        5 2019--… NA       NA     
 8      8 cm_raw                378 AMITRYPTYL…       4 2020  … BEFORE   SCREEN…
 9      9 cm_raw                378 BENADRYL          1 2020-0… NA       NA     
10     10 cm_raw                378 DIPHENHYDR…       2 2020-0… BEFORE   SCREEN…
11     11 cm_raw                378 TETRACYCLI…       3 2020-0… BEFORE   SCREEN…
12     12 cm_raw                379 BENADRYL          1 2020--… NA       NA     
13     13 cm_raw                379 SOMINEX           2 NA    … NA       NA     
14     14 cm_raw                379 ZQUILL            3 NA    … NA       NA     
# ℹ 3 more variables: CMDOSFRQ <chr>, CMDOSU <chr>, CMMODIFY <chr>
> colnames(cm)
 [1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
 [5] "CMGRPID"        "CMSTDTC"        "CMSTRTPT"       "CMSTTPT"       
 [9] "CMDOSFRQ"       "CMDOSU"         "CMMODIFY"  


Another way to achieve the same outcome is by moving the ‘condition_by’ 
call up one level, as illustrated below: it is not required to use the
{magrittr} pipe %>% or curly braces in this case.

cm <- cm %>%
  condition_add(MODIFY != CMTRT, .dat2 = cm_raw) %>%
  assign_no_ct(
    raw_dat = cm_raw,
    raw_var = "MODIFY",
    tgt_var = "CMMODIFY",
    id_vars = oak_id_vars()
  ) 

  cm
# A tibble: 14 × 11
   oak_id raw_source patient_number CMTRT       CMGRPID CMSTDTC CMSTRTPT CMSTTPT
    <int> <chr>               <int> <chr>         <int> <iso86> <chr>    <chr>  
 1      1 cm_raw                375 BABY ASPIR…       1 NA    … BEFORE   SCREEN…
 2      2 cm_raw                375 CORTISPORIN       2 2020-0… NA       NA     
 3      3 cm_raw                376 ASPIRIN           1 2021-0… NA       NA     
 4      4 cm_raw                377 DIPHENHYDR…       1 2020-1… NA       NA     
 5      5 cm_raw                377 PARCETEMOL        2 2020-0… NA       NA     
 6      6 cm_raw                377 VOMIKIND          3 2019  … NA       NA     
 7      7 cm_raw                377 ZENFLOX OZ        5 2019--… NA       NA     
 8      8 cm_raw                378 AMITRYPTYL…       4 2020  … BEFORE   SCREEN…
 9      9 cm_raw                378 BENADRYL          1 2020-0… NA       NA     
10     10 cm_raw                378 DIPHENHYDR…       2 2020-0… BEFORE   SCREEN…
11     11 cm_raw                378 TETRACYCLI…       3 2020-0… BEFORE   SCREEN…
12     12 cm_raw                379 BENADRYL          1 2020--… NA       NA     
13     13 cm_raw                379 SOMINEX           2 NA    … NA       NA     
14     14 cm_raw                379 ZQUILL            3 NA    … NA       NA     
# ℹ 3 more variables: CMDOSFRQ <chr>, CMDOSU <chr>, CMMODIFY <chr>
> colnames(cm)
 [1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
 [5] "CMGRPID"        "CMSTDTC"        "CMSTRTPT"       "CMSTTPT"       
 [9] "CMDOSFRQ"       "CMDOSU"         "CMMODIFY" 
 
####################################################################################
Now, complete mapping the rest of the SDTM variables.

cm <- cm %>%
  # Map CMINDC as the collected value in MDIND to CM.CMINDC
  assign_no_ct(
    raw_dat = cm_raw,
    raw_var = "MDIND",
    tgt_var = "CMINDC",
    id_vars = oak_id_vars()
  ) %>%
  # Map CMENDTC as the collected value in MDEDR and MDETM to CM.CMENDTC.
  # This function calls create_iso8601
  assign_datetime(
    raw_dat = cm_raw,
    raw_var = c("MDEDR", "MDETM"),
    tgt_var = "CMENDTC",
    raw_fmt = c("d-m-y", "H:M"),
    raw_unk = c("UN", "UNK")
  ) %>%
  # Map qualifier CMENRTPT as If MDONG == 1 then CM.CMENRTPT = 'ONGOING'
  hardcode_ct(
    raw_dat = condition_add(cm_raw, MDONG == "1"),
    raw_var = "MDONG",
    tgt_var = "CMENRTPT",
    tgt_val = "ONGOING",
    ct_spec = study_ct,
    ct_clst = "C66728",
    id_vars = oak_id_vars()
  ) %>%
  # Map qualifier CMENTPT as If MDONG == 1 then CM.CMENTPT = 'DATE OF LAST ASSESSMENT'
  hardcode_no_ct(
    raw_dat = condition_add(cm_raw, MDONG == "1"),
    raw_var = "MDONG",
    tgt_var = "CMENTPT",
    tgt_val = "DATE OF LAST ASSESSMENT",
    id_vars = oak_id_vars()
  ) %>%
  # Map qualifier CMDOS as If collected value in raw_var DOS is numeric then CM.CMDOSE
  assign_no_ct(
    raw_dat = condition_add(cm_raw, is.numeric(DOS)),
    raw_var = "DOS",
    tgt_var = "CMDOS",
    id_vars = oak_id_vars()
  ) %>%
  # Map qualifier CMDOS as If collected value in raw_var DOS is character then CM.CMDOSTXT
  assign_no_ct(
    raw_dat = condition_add(cm_raw, is.character(DOS)),
    raw_var = "DOS",
    tgt_var = "CMDOSTXT",
    id_vars = oak_id_vars()
  ) %>%
  # Map qualifier CMDOSU as the collected value in the cm_raw dataset DOSU variable to CM.CMDOSU
  assign_ct(
    raw_dat = cm_raw,
    raw_var = "DOSU",
    tgt_var = "CMDOSU",
    ct_spec = study_ct,
    ct_clst = "C71620",
    id_vars = oak_id_vars()
  ) %>%
  # Map qualifier CMDOSFRM as the collected value in the cm_raw dataset MDFORM variable to CM.CMDOSFRM
  assign_ct(
    raw_dat = cm_raw,
    raw_var = "MDFORM",
    tgt_var = "CMDOSFRM",
    ct_spec = study_ct,
    ct_clst = "C66726",
    id_vars = oak_id_vars()
  ) %>%
  # Map CMROUTE as the collected value in the cm_raw dataset MDRTE variable to CM.CMROUTE
  assign_ct(
    raw_dat = cm_raw,
    raw_var = "MDRTE",
    tgt_var = "CMROUTE",
    ct_spec = study_ct,
    ct_clst = "C66729",
    id_vars = oak_id_vars()
  ) %>%
  # Map qualifier CMPROPH as If MDPROPH == 1 then CM.CMPROPH = 'Y'
  hardcode_ct(
    raw_dat = condition_add(cm_raw, MDPROPH == "1"),
    raw_var = "MDPROPH",
    tgt_var = "CMPROPH",
    tgt_val = "Y",
    ct_spec = study_ct,
    ct_clst = "C66742",
    id_vars = oak_id_vars()
  ) %>%
  # Map CMDRG as the collected value in the cm_raw dataset CMDRG variable to CM.CMDRG
  assign_no_ct(
    raw_dat = cm_raw,
    raw_var = "CMDRG",
    tgt_var = "CMDRG",
    id_vars = oak_id_vars()
  ) %>%
  # Map CMDRGCD as the collected value in the cm_raw dataset CMDRGCD variable to CM.CMDRGCD
  assign_no_ct(
    raw_dat = cm_raw,
    raw_var = "CMDRGCD",
    tgt_var = "CMDRGCD",
    id_vars = oak_id_vars()
  ) %>%
  # Map CMDECOD as the collected value in the cm_raw dataset CMDECOD variable to CM.CMDECOD
  assign_no_ct(
    raw_dat = cm_raw,
    raw_var = "CMDECOD",
    tgt_var = "CMDECOD",
    id_vars = oak_id_vars()
  ) %>%
  # Map CMPNCD as the collected value in the cm_raw dataset CMPNCD variable to CM.CMPNCD
  assign_no_ct(
    raw_dat = cm_raw,
    raw_var = "CMPNCD",
    tgt_var = "CMPNCD",
    id_vars = oak_id_vars()
  )

# Warning message:
# There were 4 parsing problems. Run `problems()` on parsed results for details. 
> cm
# A tibble: 14 × 24
   oak_id raw_source patient_number CMTRT       CMGRPID CMSTDTC CMSTRTPT CMSTTPT
    <int> <chr>               <int> <chr>         <int> <iso86> <chr>    <chr>  
 1      1 cm_raw                375 BABY ASPIR…       1 NA    … BEFORE   SCREEN…
 2      2 cm_raw                375 CORTISPORIN       2 2020-0… NA       NA     
 3      3 cm_raw                376 ASPIRIN           1 2021-0… NA       NA     
 4      4 cm_raw                377 DIPHENHYDR…       1 2020-1… NA       NA     
 5      5 cm_raw                377 PARCETEMOL        2 2020-0… NA       NA     
 6      6 cm_raw                377 VOMIKIND          3 2019  … NA       NA     
 7      7 cm_raw                377 ZENFLOX OZ        5 2019--… NA       NA     
 8      8 cm_raw                378 AMITRYPTYL…       4 2020  … BEFORE   SCREEN…
 9      9 cm_raw                378 BENADRYL          1 2020-0… NA       NA     
10     10 cm_raw                378 DIPHENHYDR…       2 2020-0… BEFORE   SCREEN…
11     11 cm_raw                378 TETRACYCLI…       3 2020-0… BEFORE   SCREEN…
12     12 cm_raw                379 BENADRYL          1 2020--… NA       NA     
13     13 cm_raw                379 SOMINEX           2 NA    … NA       NA     
14     14 cm_raw                379 ZQUILL            3 NA    … NA       NA     
# ℹ 16 more variables: CMDOSFRQ <chr>, CMMODIFY <chr>, CMINDC <chr>,
#   CMENDTC <iso8601>, CMENRTPT <chr>, CMENTPT <chr>, CMDOS <int>,
#   CMDOSTXT <int>, CMDOSU <chr>, CMDOSFRM <chr>, CMROUTE <chr>, CMPROPH <chr>,
#   CMDRG <chr>, CMDRGCD <dbl>, CMDECOD <chr>, CMPNCD <dbl>
> colnames(cm)
 [1] "oak_id"         "raw_source"     "patient_number" "CMTRT"         
 [5] "CMGRPID"        "CMSTDTC"        "CMSTRTPT"       "CMSTTPT"       
 [9] "CMDOSFRQ"       "CMMODIFY"       "CMINDC"         "CMENDTC"       
[13] "CMENRTPT"       "CMENTPT"        "CMDOS"          "CMDOSTXT"      
[17] "CMDOSU"         "CMDOSFRM"       "CMROUTE"        "CMPROPH"       
[21] "CMDRG"          "CMDRGCD"        "CMDECOD"        "CMPNCD"        

####################################################################################


Repeat Map Topic and Map Rest

There is only one topic variable in this raw data source, and there are no additional 
topic variable mappings. Users can proceed to the next step. This is required 
only if there is more than one topic variable to map.

Create SDTM derived variables

The SDTM derived variables or any SDTM mapping that is applicable to all the records
in the cm dataset produced in the previous step cam be created now. In this example, 
we will create the CMSEQ variable. The mapping logic is Create a sequence number for each record in the CM domain.

cm <- cm %>%
  # The below mappings are applicable to all the records in the cm domain,
  # hence can be derived using mutate statement.
  dplyr::mutate(
    STUDYID = "test_study",
    DOMAIN = "CM",
    CMCAT = "GENERAL CONMED",
    USUBJID = paste0("test_study", "-", cm_raw$PATNUM)
  ) %>%
  # derive sequence number
  # derive_seq(tgt_var = "CMSEQ",
  #            rec_vars= c("USUBJID", "CMGRPID")) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "CMENDTC",
    refdt = "RFXSTDTC",
    study_day_var = "CMENDY"
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "CMSTDTC",
    refdt = "RFXSTDTC",
    study_day_var = "CMSTDY"
  ) %>%
  # Add code for derive Baseline flag.
  dplyr::select("STUDYID", "DOMAIN", "USUBJID", everything())

 cm
# A tibble: 14 × 30
   STUDYID    DOMAIN USUBJID      oak_id raw_source patient_number CMTRT CMGRPID
   <chr>      <chr>  <chr>         <int> <chr>               <int> <chr>   <int>
 1 test_study CM     test_study-…      1 cm_raw                375 BABY…       1
 2 test_study CM     test_study-…      2 cm_raw                375 CORT…       2
 3 test_study CM     test_study-…      3 cm_raw                376 ASPI…       1
 4 test_study CM     test_study-…      4 cm_raw                377 DIPH…       1
 5 test_study CM     test_study-…      5 cm_raw                377 PARC…       2
 6 test_study CM     test_study-…      6 cm_raw                377 VOMI…       3
 7 test_study CM     test_study-…      7 cm_raw                377 ZENF…       5
 8 test_study CM     test_study-…      8 cm_raw                378 AMIT…       4
 9 test_study CM     test_study-…      9 cm_raw                378 BENA…       1
10 test_study CM     test_study-…     10 cm_raw                378 DIPH…       2
11 test_study CM     test_study-…     11 cm_raw                378 TETR…       3
12 test_study CM     test_study-…     12 cm_raw                379 BENA…       1
13 test_study CM     test_study-…     13 cm_raw                379 SOMI…       2
14 test_study CM     test_study-…     14 cm_raw                379 ZQUI…       3
# ℹ 22 more variables: CMSTDTC <date>, CMSTRTPT <chr>, CMSTTPT <chr>,
#   CMDOSFRQ <chr>, CMMODIFY <chr>, CMINDC <chr>, CMENDTC <date>,
#   CMENRTPT <chr>, CMENTPT <chr>, CMDOS <int>, CMDOSTXT <int>, CMDOSU <chr>,
#   CMDOSFRM <chr>, CMROUTE <chr>, CMPROPH <chr>, CMDRG <chr>, CMDRGCD <dbl>,
#   CMDECOD <chr>, CMPNCD <dbl>, CMCAT <chr>, CMENDY <int>, CMSTDY <int>
> colnames(cm)
 [1] "STUDYID"        "DOMAIN"         "USUBJID"        "oak_id"        
 [5] "raw_source"     "patient_number" "CMTRT"          "CMGRPID"       
 [9] "CMSTDTC"        "CMSTRTPT"       "CMSTTPT"        "CMDOSFRQ"      
[13] "CMMODIFY"       "CMINDC"         "CMENDTC"        "CMENRTPT"      
[17] "CMENTPT"        "CMDOS"          "CMDOSTXT"       "CMDOSU"        
[21] "CMDOSFRM"       "CMROUTE"        "CMPROPH"        "CMDRG"         
[25] "CMDRGCD"        "CMDECOD"        "CMPNCD"         "CMCAT"         
[29] "CMENDY"         "CMSTDY"        
> 
##################################################################################
##################################################################################
Findings SDTM domain

how to create a Findings SDTM domain using the {sdtm.oak} package. 
Examples are currently presented and tested in the context of the VS domain.

Read in data

Read all the raw datasets into the environment. 
In this example, the raw dataset name is vs_raw. Users can read it from the package using the below code:

vs_raw <- read.csv(system.file("raw_data/vitals_raw_data.csv",
  package = "sdtm.oak"
))

> vs_raw
       STUDY PATNUM   SUBJSTAT     SITENM  INSTANCE  FORM       FORML DATAPGID
1 Test Study    375 Randomized Test Study    VISIT1 VTLS1 Vital Signs  1752329
2 Test Study    375 Randomized Test Study    VISIT1 VTLS1 Vital Signs  8153061
3 Test Study    375 Randomized Test Study Screening VTLS1 Vital Signs  3463516
4 Test Study    376 Randomized Test Study Screening VTLS1 Vital Signs  8423253
5 Test Study    376 Randomized Test Study    VISIT1 VTLS1 Vital Signs  1211365
6 Test Study    376 Randomized Test Study    VISIT1 VTLS1 Vital Signs  5880552
  RECORDID RECPOS ASMNTDN     TMPTC      VTLD VTLTM         SUBPOS SYS_BP
1  5734754      0       0  Pre-dose 16-May-15  7:25          PRONE    158
2  3712412      1       0 Post-dose 16-May-15 10:25 SEMI-RECUMBENT     94
3  1229594      0       0            6-May-18  2:01          PRONE    117
4  9767053      0       1                                              NA
5  1567778      0       0  Pre-dose 23-Oct-08  1:19          PRONE     85
6  7060998      0       0 Post-dose 23-Oct-08  3:19          PRONE    126
  DIA_BP PULSE RESPRT  TEMP           TEMPLOC OXY_SAT   LAT    LOC
1     92    63     17 40.48              SKIN      98 RIGHT FINGER
2     78    76     20 36.75 TYMPANIC MEMBRANE      99  LEFT FINGER
3     62    66     15 29.45       ORAL CAVITY      96  LEFT FINGER
4     NA    NA     NA    NA                        NA             
5     68    73     21 38.25            AXILLA      93 RIGHT FINGER
6     81    56     18 38.08 TYMPANIC MEMBRANE      93  LEFT FINGER
              VSO2SRC           NEWS107
1 MASK OXYGEN THERAPY      UNRESPONSIVE
2            ROOM AIR     NEW CONFUSION
3            ROOM AIR VERBAL RESPONSIVE
4                                      
5            ROOM AIR             ALERT
6 MASK OXYGEN THERAPY   PAIN RESPONSIVE
> colnames(vs_raw)
 [1] "STUDY"    "PATNUM"   "SUBJSTAT" "SITENM"   "INSTANCE" "FORM"    
 [7] "FORML"    "DATAPGID" "RECORDID" "RECPOS"   "ASMNTDN"  "TMPTC"   
[13] "VTLD"     "VTLTM"    "SUBPOS"   "SYS_BP"   "DIA_BP"   "PULSE"   
[19] "RESPRT"   "TEMP"     "TEMPLOC"  "OXY_SAT"  "LAT"      "LOC"     
[25] "VSO2SRC"  "NEWS107" 
##################################################################################

Create oak_id_vars
Read in the DM domain

vs_raw <- vs_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "vitals"
  )

> colnames(vs_raw)
 [1] "oak_id"         "raw_source"     "patient_number" "STUDY"         
 [5] "PATNUM"         "SUBJSTAT"       "SITENM"         "INSTANCE"      
 [9] "FORM"           "FORML"          "DATAPGID"       "RECORDID"      
[13] "RECPOS"         "ASMNTDN"        "TMPTC"          "VTLD"          
[17] "VTLTM"          "SUBPOS"         "SYS_BP"         "DIA_BP"        
[21] "PULSE"          "RESPRT"         "TEMP"           "TEMPLOC"       
[25] "OXY_SAT"        "LAT"            "LOC"            "VSO2SRC"       
[29] "NEWS107"       
> vs_raw
  oak_id raw_source patient_number      STUDY PATNUM   SUBJSTAT     SITENM
1      1     vitals            375 Test Study    375 Randomized Test Study
2      2     vitals            375 Test Study    375 Randomized Test Study
3      3     vitals            375 Test Study    375 Randomized Test Study
4      4     vitals            376 Test Study    376 Randomized Test Study
5      5     vitals            376 Test Study    376 Randomized Test Study
6      6     vitals            376 Test Study    376 Randomized Test Study
   INSTANCE  FORM       FORML DATAPGID RECORDID RECPOS ASMNTDN     TMPTC
1    VISIT1 VTLS1 Vital Signs  1752329  5734754      0       0  Pre-dose
2    VISIT1 VTLS1 Vital Signs  8153061  3712412      1       0 Post-dose
3 Screening VTLS1 Vital Signs  3463516  1229594      0       0          
4 Screening VTLS1 Vital Signs  8423253  9767053      0       1          
5    VISIT1 VTLS1 Vital Signs  1211365  1567778      0       0  Pre-dose
6    VISIT1 VTLS1 Vital Signs  5880552  7060998      0       0 Post-dose
       VTLD VTLTM         SUBPOS SYS_BP DIA_BP PULSE RESPRT  TEMP
1 16-May-15  7:25          PRONE    158     92    63     17 40.48
2 16-May-15 10:25 SEMI-RECUMBENT     94     78    76     20 36.75
3  6-May-18  2:01          PRONE    117     62    66     15 29.45
4                                    NA     NA    NA     NA    NA
5 23-Oct-08  1:19          PRONE     85     68    73     21 38.25
6 23-Oct-08  3:19          PRONE    126     81    56     18 38.08
            TEMPLOC OXY_SAT   LAT    LOC             VSO2SRC           NEWS107
1              SKIN      98 RIGHT FINGER MASK OXYGEN THERAPY      UNRESPONSIVE
2 TYMPANIC MEMBRANE      99  LEFT FINGER            ROOM AIR     NEW CONFUSION
3       ORAL CAVITY      96  LEFT FINGER            ROOM AIR VERBAL RESPONSIVE
4                        NA                                                   
5            AXILLA      93 RIGHT FINGER            ROOM AIR             ALERT
6 TYMPANIC MEMBRANE      93  LEFT FINGER MASK OXYGEN THERAPY   PAIN RESPONSIVE
> 

###################################################################################
Read in CT

Controlled Terminology is part of the SDTM specification and it is prepared by the user. 
In this example, the study controlled terminology name is sdtm_ct.csv. Users can read it from the package using the below code:

study_ct <- read.csv(system.file("raw_data/sdtm_ct.csv",
  package = "sdtm.oak"
))

> study_ct
   codelist_code term_code               term_value
1         C66726    C25158                  CAPSULE
2         C66726    C25394                     PILL
3         C66726    C29167                   LOTION
4         C66726    C42887                  AEROSOL
5         C66726    C42944                 INHALANT
6         C66726    C42946                INJECTION
7         C66726    C42953                   LIQUID
8         C66726    C42998                   TABLET
9         C66728    C25629                   BEFORE
10        C66728    C53279                  ONGOING
11        C66729    C28161            INTRAMUSCULAR
12        C66729    C38210                 EPIDURAL
13        C66729    C38222           INTRA-ARTERIAL
14        C66729    C38223          INTRA-ARTICULAR
15        C66729    C38287               OPHTHALMIC
16        C66729    C38288                     ORAL
17        C66729    C38305              TRANSDERMAL
18        C66729    C38311                  UNKNOWN
19        C66734    C49568                       CM
20        C66741   C174446                     TEMP
21        C66741    C25298                    SYSBP
22        C66741    C25299                    DIABP
23        C66741    C49676                    PULSE
24        C66741    C49678                     RESP
25        C66741    C60832                   OXYSAT
26        C66741    V00224                    VSALL
27        C66742    C49488                        Y
28        C66770    C25613                        %
29        C66770    C42559                        C
30        C66770    C49670                     mmHg
31        C66770    C49673                beats/min
32        C66770    C49674              breaths/min
33        C66789    C49484                 NOT DONE
34        C67153   C174446              Temperature
35        C67153    C25298  Systolic Blood Pressure
36        C67153    C25299 Diastolic Blood Pressure
37        C67153    C49676               Pulse Rate
38        C67153    C49678         Respiratory Rate
39        C67153    C60832        Oxygen Saturation
40        C67153    V00224              Vital Signs
41        C71113    C25473                       QD
42        C71113    C64496                      BID
43        C71113    C64499                      PRN
44        C71113    C64516                      Q2H
45        C71113    C64530                      QID
46        C71148   C111310           SEMI-RECUMBENT
47        C71148    C62122                  SITTING
48        C71148    C62165                    PRONE
49        C71148    C62166                 STANDING
50        C71148    C62167                   SUPINE
51        C71620    C25613                        %
52        C71620    C28253                       mg
53        C71620    C28254                       mL
54        C71620    C48155                        g
55        C71620    C48480                  CAPSULE
56        C71620    C48542                   TABLET
57        C71620    C48579                       IU
58        C74456    C12390                   RECTUM
59        C74456    C12421              ORAL CAVITY
60        C74456    C12470                     SKIN
61        C74456    C12502        TYMPANIC MEMBRANE
62        C74456    C12674                   AXILLA
63        C74456    C32608                   FINGER
64        C74456    C89803                 FOREHEAD
65        C99073    C25228                    RIGHT
66        C99073    C25229                     LEFT
67           TPT       TPT                  PREDOSE
68           TPT       TPT                 POSTDOSE
69        TPTNUM    TPTNUM                        1
70        TPTNUM    TPTNUM                        2
71      VISITNUM  VISITNUM                        1
72      VISITNUM  VISITNUM                        2
73         VISIT     VISIT                SCREENING
74         VISIT     VISIT                  VISIT 1
                 collected_value                    term_preferred_term
1                        Capsule                    Capsule Dosage Form
2                           Pill                       Pill Dosage Form
3                         Lotion                     Lotion Dosage Form
4                        Aerosol                    Aerosol Dosage Form
5                       Inhalant                   Inhalant Dosage Form
6                      Injection                 Injectable Dosage Form
7                         Liquid                     Liquid Dosage Form
8                         Tablet                     Tablet Dosage Form
9                          Prior                                  Prior
10                      Continue                               Continue
11            IM (Intramuscular)  Intramuscular Route of Administration
12                 EP (Epidural)       Epidural Route of Administration
13           IA (Intra-arterial)  Intraarterial Route of Administration
14          IJ (Intra-articular) Intraarticular Route of Administration
15               OP (Ophthalmic)     Ophthalmic Route of Administration
16                     PO (Oral)           Oral Route of Administration
17              DE (Transdermal)    Transdermal Route of Administration
18                       Unknown        Unknown Route of Administration
19 Concomitant Medication Domain          Concomitant Medication Domain
20              Body Temperature                       Body Temperature
21       Systolic Blood Pressure                Systolic Blood Pressure
22      Diastolic Blood Pressure               Diastolic Blood Pressure
23                    Pulse Rate                             Pulse Rate
24              Respiratory Rate                       Respiratory Rate
25 Oxygen Saturation Measurement          Oxygen Saturation Measurement
26           VS Domain ALL Tests                    VS Domain ALL Tests
27                           Yes                                    Yes
28                    Percentage                             Percentage
29                Degree Celsius                         Degree Celsius
30         Millimeter of Mercury                  Millimeter of Mercury
31              Beats per Minute                       Beats per Minute
32            Breaths per Minute                     Breaths per Minute
33                      Not Done                               Not Done
34              Body Temperature                       Body Temperature
35       Systolic Blood Pressure                Systolic Blood Pressure
36      Diastolic Blood Pressure               Diastolic Blood Pressure
37                    Pulse Rate                             Pulse Rate
38              Respiratory Rate                       Respiratory Rate
39 Oxygen Saturation Measurement          Oxygen Saturation Measurement
40           VS Domain ALL Tests                    VS Domain ALL Tests
41                QD (Every Day)                                  Daily
42             BID (Twice a Day)                            Twice Daily
43               PRN (As Needed)                              As Needed
44           Q2H (Every 2 Hours)                        Every Two Hours
45           QID (4 Times a Day)                       Four Times Daily
46                   Semi-Supine                            Semi-Supine
47                       Sitting                                Sitting
48                         Prone                                  Prone
49                      Standing                               Standing
50                        Supine                                 Supine
51                             %                             Percentage
52                            mg                              Milligram
53                            mL                             Milliliter
54                             g                                   Gram
55                       Capsule                    Capsule Dosing Unit
56                        Tablet                     Tablet Dosing Unit
57                            IU                     International Unit
58                        Rectum                                 Rectum
59                   Oral Cavity                            Oral Cavity
60                          Skin                                   Skin
61             Tympanic Membrane                      Tympanic Membrane
62                        Axilla                                 Axilla
63                        FINGER                                 FINGER
64                      Forehead                               Forehead
65                         Right                                  Right
66                          Left                                   Left
67                      Pre-dose                                       
68                     Post-dose                                       
69                      Pre-dose                                       
70                     Post-dose                                       
71                     Screening                                       
72                       Visit 1                                       
73                     Screening                                       
74                       Visit 1                                       
                           term_synonyms
1                                    cap
2                                       
3                                       
4                                    aer
5                                       
6                                       
7                                       
8                                    tab
9                                       
10                            Continuous
11                                      
12                                      
13                                      
14                                      
15                                      
16 Intraoral Route of Administration; PO
17                                      
18                                      
19         Concomitant/Prior Medications
20         Body Temperature; Temperature
21               Systolic Blood Pressure
22              Diastolic Blood Pressure
23                            Pulse Rate
24                      Respiratory Rate
25                     Oxygen Saturation
26                                      
27                                   Yes
28                            Percentage
29                        Degree Celsius
30                 Millimeter of Mercury
31            Beats per Minute; BPM; bpm
32                    Breaths per Minute
33                                      
34         Body Temperature; Temperature
35               Systolic Blood Pressure
36              Diastolic Blood Pressure
37                            Pulse Rate
38                      Respiratory Rate
39                     Oxygen Saturation
40                                      
41                  /day; Daily; Per Day
42                     BD; Twice per day
43                             As needed
44                         Every 2 hours
45                       4 times per day
46                           Semi-Supine
47                               Sitting
48                                 Prone
49                 Orthostatic; Standing
50                                Supine
51                            Percentage
52                             Milligram
53                       cm3; Milliliter
54                                  Gram
55              cap; Capsule Dosing Unit
56               tab; Tablet Dosing Unit
57                IE; International Unit
58                                      
59                  Buccal cavity; Mouth
60                      Integument; Skin
61                     Tympanic Membrane
62                        Armpit; Axilla
63                                Finger
64                              Forehead
65                                      
66                                      
67                                      
68                                      
69                                      
70                                      
71                                      
72                                      
73                                      
74                                      
> colnames(study_ct)
[1] "codelist_code"       "term_code"           "term_value"         
[4] "collected_value"     "term_preferred_term" "term_synonyms"
#######################################################################################

Map Topic Variable

This raw dataset has multiple topic variables. Lets start with the first topic variable. 
Map topic variable SYSBP from the raw variable SYS_BP.

# Map topic variable SYSBP and its qualifiers.
vs_sysbp <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "SYS_BP",
    tgt_var = "VSTESTCD",
    tgt_val = "SYSBP",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  # Filter for records where VSTESTCD is not empty.
  # Only these records need qualifier mappings.
  dplyr::filter(!is.na(.data$VSTESTCD))


   colnames(vs_sysbp)
[1] "oak_id"         "raw_source"     "patient_number" "VSTESTCD"      
> head(vs_sysbp)
# A tibble: 5 × 4
  oak_id raw_source patient_number VSTESTCD
   <int> <chr>               <int> <chr>   
1      1 vitals                375 SYSBP   
2      2 vitals                375 SYSBP   
3      3 vitals                375 SYSBP   
4      5 vitals                376 SYSBP   
5      6 vitals                376 SYSBP   
> 
#######################################################################################

Map Rest of the Variables

Map rest of the variables applicable to the topic variable SYSBP. 
This can include qualifiers, identifier and timing variables.

# Map topic variable SYSBP and its qualifiers.
vs_sysbp <- vs_sysbp %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "SYS_BP",
    tgt_var = "VSTEST",
    tgt_val = "Systolic Blood Pressure",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "SYS_BP",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "SYS_BP",
    tgt_var = "VSORRESU",
    tgt_val = "mmHg",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSPOS using assign_ct algorithm
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "SUBPOS",
    tgt_var = "VSPOS",
    ct_spec = study_ct,
    ct_clst = "C71148",
    id_vars = oak_id_vars()
  )

    colnames(vs_sysbp)
[1] "oak_id"         "raw_source"     "patient_number" "VSTESTCD"      
[5] "VSTEST"         "VSORRES"        "VSORRESU"       "VSPOS"         
> vs_sysbp <- vs_sysbp %>%
  head(vs_sysbp)ode_ct algorithm
  head(vs_sysbp)
# A tibble: 5 × 8
  oak_id raw_source patient_number VSTESTCD VSTEST        VSORRES VSORRESU VSPOS
   <int> <chr>               <int> <chr>    <chr>           <int> <chr>    <chr>
1      1 vitals                375 SYSBP    Systolic Blo…     158 mmHg     PRONE
2      2 vitals                375 SYSBP    Systolic Blo…      94 mmHg     SEMI…
3      3 vitals                375 SYSBP    Systolic Blo…     117 mmHg     PRONE
4      5 vitals                376 SYSBP    Systolic Blo…      85 mmHg     PRONE
5      6 vitals                376 SYSBP    Systolic Blo…     126 mmHg     PRONE
> 


#######################################################################################

Repeat Map Topic and Map Rest

This raw data source has other topic variables DIABP, PULSE, RESP, TEMP, OXYSAT, VSALL and its corresponding qualifiers. Repeat mapping topic and qualifiers for each topic variable.

# Map topic variable DIABP and its qualifiers.
vs_diabp <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "DIA_BP",
    tgt_var = "VSTESTCD",
    tgt_val = "DIABP",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "DIA_BP",
    tgt_var = "VSTEST",
    tgt_val = "Diastolic Blood Pressure",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "DIA_BP",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "DIA_BP",
    tgt_var = "VSORRESU",
    tgt_val = "mmHg",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSPOS using assign_ct algorithm
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "SUBPOS",
    tgt_var = "VSPOS",
    ct_spec = study_ct,
    ct_clst = "C71148",
    id_vars = oak_id_vars()
  )

# Map topic variable PULSE and its qualifiers.
vs_pulse <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "PULSE",
    tgt_var = "VSTESTCD",
    tgt_val = "PULSE",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "PULSE",
    tgt_var = "VSTEST",
    tgt_val = "Pulse Rate",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "PULSE",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "PULSE",
    tgt_var = "VSORRESU",
    tgt_val = "beats/min",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  )

# Map topic variable RESP from the raw variable RESPRT and its qualifiers.
vs_resp <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "RESPRT",
    tgt_var = "VSTESTCD",
    tgt_val = "RESP",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "RESPRT",
    tgt_var = "VSTEST",
    tgt_val = "Respiratory Rate",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "RESPRT",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "RESPRT",
    tgt_var = "VSORRESU",
    tgt_val = "breaths/min",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  )

# Map topic variable TEMP from raw variable TEMP and its qualifiers.
vs_temp <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "TEMP",
    tgt_var = "VSTESTCD",
    tgt_val = "TEMP",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "TEMP",
    tgt_var = "VSTEST",
    tgt_val = "Temperature",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "TEMP",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "TEMP",
    tgt_var = "VSORRESU",
    tgt_val = "C",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSLOC from TEMPLOC using assign_ct
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "TEMPLOC",
    tgt_var = "VSLOC",
    ct_spec = study_ct,
    ct_clst = "C74456",
    id_vars = oak_id_vars()
  )

# Map topic variable OXYSAT from raw variable OXY_SAT and its qualifiers.
vs_oxysat <-
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "OXY_SAT",
    tgt_var = "VSTESTCD",
    tgt_val = "OXYSAT",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "OXY_SAT",
    tgt_var = "VSTEST",
    tgt_val = "Oxygen Saturation",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRES using assign_no_ct algorithm
  assign_no_ct(
    raw_dat = vs_raw,
    raw_var = "OXY_SAT",
    tgt_var = "VSORRES",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSORRESU using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "OXY_SAT",
    tgt_var = "VSORRESU",
    tgt_val = "%",
    ct_spec = study_ct,
    ct_clst = "C66770",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSLAT using assign_ct from raw variable LAT
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "LAT",
    tgt_var = "VSLAT",
    ct_spec = study_ct,
    ct_clst = "C99073",
    id_vars = oak_id_vars()
  ) %>%
  # Map VSLOC using assign_ct from raw variable LOC
  assign_ct(
    raw_dat = vs_raw,
    raw_var = "LOC",
    tgt_var = "VSLOC",
    ct_spec = study_ct,
    ct_clst = "C74456",
    id_vars = oak_id_vars()
  )

# Map topic variable VSALL from raw variable ASMNTDN with the logic if ASMNTDN  == 1 then VSTESTCD = VSALL
vs_vsall <-
  hardcode_ct(
    raw_dat = condition_add(vs_raw, ASMNTDN == 1L),
    raw_var = "ASMNTDN",
    tgt_var = "VSTESTCD",
    tgt_val = "VSALL",
    ct_spec = study_ct,
    ct_clst = "C66741"
  ) %>%
  dplyr::filter(!is.na(.data$VSTESTCD)) %>%
  # Map VSTEST using hardcode_ct algorithm
  hardcode_ct(
    raw_dat = vs_raw,
    raw_var = "ASMNTDN",
    tgt_var = "VSTEST",
    tgt_val = "Vital Signs",
    ct_spec = study_ct,
    ct_clst = "C67153",
    id_vars = oak_id_vars()
  )

  ##############################################################################################################

  Create SDTM derived variables

Create derived variables applicable to all topic variables.

vs <- vs %>%
  dplyr::mutate(
    STUDYID = "test_study",
    DOMAIN = "VS",
    VSCAT = "VITAL SIGNS",
    USUBJID = paste0("test_study", "-", .data$patient_number)
  ) %>%
  # derive_seq(tgt_var = "VSSEQ",
  #            rec_vars= c("USUBJID", "VSTRT")) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "VSDTC",
    refdt = "RFXSTDTC",
    study_day_var = "VSDY"
  ) %>%
  dplyr::select("STUDYID", "DOMAIN", "USUBJID", everything()


  ##############################################################################################################
  
