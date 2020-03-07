setwd("~/Documents/stanford/grant/2019/ot2/work/")

##
#parse curation. have to specify file every time
#name convention: output file name starts with curator name.
#input_file = "data/curation/Breast_cancer_CLINICALTRIAL_v7.xlsx"
#output_file = "data/parsed/Ben_Breast_cancer_CLINICALTRIAL_v7.csv"

input_file = "data/curation/FDA-drug_biomarkers-v8.xlsx"
output_file = "data/parsed/Ben_FDA-drug_biomarkers-v8.csv"

#input_file = "data/curation/Livercancer2010_2011.xlsx"
#output_file = "data/parsed/AustinTyler_Livercancer.csv"

#input_file = "data/curation/Breast_Cancer_austin.xlsx"
#output_file = "data/parsed/Austin_Breast_Cancer.csv"

#input_file = "data/curation/Breast_Cancer_tyler.xlsx"
#output_file = "data/parsed/Tyler_Breast_Cancer.csv"


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

