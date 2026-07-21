#################################################################################
SDTM implementation for NON CLINICAL DATA. (SENDIG)
#################################################################################
Standard for exchange non clinical data implementation 

SENDIG is based on SDTM
Non clinical studies: Studies with  non involved human subjects. 
Usually to test a drug, procedure, or treatment in animals. 
With the goal of assesing safety 

Non clinical studies are often require before clinical trials in humans can be started. 

ORGANIZATION; STRUCTURe and FORMAT for exchange between organizations or to 
be submitted to a regulatory authority,
#################################################################################

SDTM + SDTMIG serves as a map that orients you on how your data FITS into the standard. 

SDTM : 3 GENERAL OBSERVATION CLASSES
  1- Interventions
  2- Events
  3- Findings

The fundamental unit of SENDIG are the DOMAINS 
  1- Interventions(SDTM) ::: SENDIG DOMAINS: Concomital medications, Exposure, Substance use.
  2- Events(SDTM) ::: SENDIG DOMAINS: Adverse event, Disposition, Medical History, Protocol Deviation, Clinical Event
  3- Findings(SDTM) ::: SENDIG DOMAINS: ECG, Ihttps://www.sthda.com/english/wiki/fastqcr-an-r-package-facilitating-quality-controls-of-sequencing-data-for-large-numbers-of-samplesncl\Escl, Labs, Physical Exam, Pharmacokinetics concentrations, 
Mycrobiology specimen, Questionnaire, SubjChar, Vital Sign, Drug Accountability, 
Pharmacokinetics parameters, Microbiology Susceptibility. 

There are also, other SPECIAL PURPOSE DATASETS (SDTM) ::: SENDIG DOMAINS:  such as Demographics, Comments, 
Subject elements (age, Gender, Weigth, Race..), Subject Visits, Familiar antecedents.
They are SPECIFIC STANDARIZED STRUCTURES for representing additional information, that 
would not otherwise fit into the general observation classes. 

DOMAINS has 3 components_: 
 1- SPECIFICATION TABLES: A list of subset of variables from the observation class to which the domain belongs
                            The set of variables available can be found in 
                            https://www.cdisc.org/standards/foundational/send/sendig-v3-1-1
                           All domains are describe in a domain table.
                            Each column show
                                    the variable,
                                    label
                                    data type
                                    Control terminology
                                    Role
                                    CDISC notes
                                    Core (say if variables is Required, expected or permissible)
 2- ASSUMPTIONS Are listed below each domain specification table, and provide the definition of the domain, 
                            and how it is used. May provide further instructions on which concept should
                            or should not be represented in the domain. Also may provide direction of
                            how specific variables should be used in various use cases. 
                            Caution: The assumtions should always be reviewed before attempting to
                            implemented the domain!!!
 3- EXAMPLES: Typically include 
                  -   A brief narrative that explains the concept that the example ilustrate. 
                  -   Next Row description may be required to explain waht individual rows 
                    in the dataset example and may higligth how the use of certain variables 
                    are required to illustrate the concept
