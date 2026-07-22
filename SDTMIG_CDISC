#################################################################################
SDTM implementation for Human Clinical Trials. (SDTMIG)
#################################################################################
ORGANIZATION, STRUCTURE, and FORMAT of STANDARD CLINICAL STUDY TABULATION. 
For INTERCHANGE between organizations
or to be SUBMITTED to a regulatory authority 

SDTM + SDTMIG serves as a map that orients you on how your data FITS into the standard. 

SDTM : 3 GENERAL OBSERVATION CLASSES
  1- Interventions
  2- Events
  3- Findings

The fundamental unit of SDTMIG are the DOMAINS 
  1- Interventions(SDTM) ::: SDTMIG DOMAINS: Concomital medications, Exposure, Substance use.
  2- Events(SDTM) ::: SDTMIG DOMAINS: Adverse event, Disposition, Medical History, Protocol Deviation, Clinical Event
  3- Findings(SDTM) ::: SDTMIG DOMAINS: ECG, Ihttps://www.sthda.com/english/wiki/fastqcr-an-r-package-facilitating-quality-controls-of-sequencing-data-for-large-numbers-of-samplesncl\Escl, Labs, Physical Exam, Pharmacokinetics concentrations, 
Mycrobiology specimen, Questionnaire, SubjChar, Vital Sign, Drug Accountability, 
Pharmacokinetics parameters, Microbiology Susceptibility. 

There are also, other SPECIAL PURPOSE DATASETS (SDTM) ::: SDTMIG DOMAINS:  such as Demographics, Comments, 
Subject elements (age, Gender, Weigth, Race..), Subject Visits, Familiar antecedents.
They are SPECIFIC STANDARIZED STRUCTURES for representing additional information, that 
would not otherwise fit into the general observation classes. 

DOMAINS has 3 components_: 
 1- SPECIFICATION TABLES: A list of subset of variables from the observation class to which the domain belongs
                            The set of variables available can be found in 
                            https://www.cdisc.org/standards/foundational/sdtm
                            https://www.cdisc.org/standards/foundational/sdtmig/sdtmig-v3-4
                           All domains are describe in a domain table.
                            Each column show
                                    the variable
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
                  -   Finally the dataset example, shows how to implement the domain for the concept
                    or concepts described. 
                    be aware!!! The more complex concepts, may require the use of more than one 
                    domain to fully illustrate them. 



#######################################################################################################
What are SDTM core variables?

Core variables are a measure of compliance with the specific SDTM-IG domain model. 
The value of a core variable shows the importance of the variable to the overall domain structure.

Variables are divided into 3 categories:

    Required              variables are needed to identify a data record, 
                                    e.g STUDYID, and USUBJID. 
                          Or, they are needed to make a record easily understood, 
                                    e.g TERM and TEST. 
                          They must always be included in the dataset and cannot be null.
  
    Expected              variables are needed to make a record useful within a specific domain. 
                          They must always be included in the dataset but they can be null for some records. 
                          If no data is collected, a comment must be included to explain why.
    
    Permissible           variables must be included in the dataset if results are collected or derived, 
                          but they can be left null or blank.

Variables from the parent class can also be inserted into the domain if required.

#######################################################################################################
