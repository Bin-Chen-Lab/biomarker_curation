setwd("~/Documents/stanford/grant/2019/ot2/work/")

##
#parse curation. have to specify file every time
#name convention: output file name starts with curator name.
input_file = "data/curation/FDA-drug_biomarkers-v8_BC_cleaned.xlsx"
output_file = "data/parsed/Ben_FDA-drug_biomarkers-v8.csv"

#input_file = "data/curation/FDA-drug_biomarkers-35-v2_BC_cleaned.xlsx"
#output_file = "data/parsed/Ben_FDA-drug_biomarkers-35-v2.csv"


input_file = "data/curation/Breast_cancer_CLINICALTRIAL_v7_BC_cleaned.xlsx" #too many failed terms
output_file = "data/parsed/Ben_Breast_cancer_CLINICALTRIAL_v7.csv"

input_file = "data/curation/Breast_Cancer_austin.xlsx"
output_file = "data/parsed/Austin_Breast_Cancer.csv"

input_file = "data/curation/Breast_Cancer_tyler.xlsx"
output_file = "data/parsed/Tyler_Breast_Cancer.csv"

input_file = "data/curation/Breast_Cancer_Clinical_Trials_Annotated.xlsx"
output_file = "data/parsed/Breast_Cancer_Clinical_Trials_Annotated.csv"

input_file = "data/curation/Liver_Clinical_Trials.xlsx"
output_file = "data/parsed/Liver_Clinical_Trials.csv"


input_file = "data/curation/Breast-Cancer-Drug_biomarkers-pubmed-v4-030920-30-revised-2.xlsx"
output_file = "data/parsed/Ben_Breast_Cancer_pubmed.csv"

input_file = "data/curation/Breast-Cancer-Drug_biomarkers-pubmed-v4-031120-40-v2.xlsx"
output_file = "data/parsed/Breast-Cancer-Drug_biomarkers-pubmed-v4-031120-40-v2.csv"


cmd = paste("Rscript code/parser.R", input_file, output_file)
system(cmd)

########
#merge all files from parser
cmd = paste("Rscript code/merger.R")
system(cmd)
#######

#match patients to biomarker records
system(paste("Rscript code/mapper_patient2biomarker.R"))

#convert biomarker records to json 
system(paste("Rscript code/converter_json.R"))

#convert biomarker records to relational database 
system(paste("Rscript code/converter_db.R"))

