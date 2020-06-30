#convert into  relational database table
#
#biomarker_record: main table
#drug (record_id, name, drugbank_id, pubchem_id)
#biomarker (record_id, name, ensembl, biomarker_type, biomarker_direction)
#disease (record_id, name, id)
#patient (patient_id, disease, resource)
#patient_biomarker (record_id, patient_id)

library("stringr")

biomarker_all = read.csv("data/merged/biomarker_all.csv", stringsAsFactors = F)

biomarker_record_tb = biomarker_all[, c("record_id", "drug", "biomarker", "biomarker_relations", "biomarker_description", "disease", "curator", "source", "source_id")]
drug_tb = NULL
biomarker_tb = NULL
disease_tb = NULL
patient_tb = NULL

for (i in 1:nrow(biomarker_all)){
  print(i)
  
  record_id = biomarker_all$record_id[i]
  #drug table
  for (j in 1:length(unlist(strsplit(biomarker_all$drug_drugbank_standard[i], ",")))){
    drugbank_id = unlist(strsplit(biomarker_all$drug_drugbank_standard[i], ","))[j]
    pubchem_id = unlist(strsplit(biomarker_all$drug_pubchem[i], ","))[j]
    drug_name = str_trim(unlist(strsplit(biomarker_all$drug[i], ",|，"))[j])
    drug_tb = rbind(drug_tb, data.frame(record_id, drug_name, drugbank_id, pubchem_id))
  }
  
  #disease table
  for (j in 1:length(unlist(strsplit(biomarker_all$diseases_id_standard[i], ",")))){
    disease_id = unlist(strsplit(biomarker_all$diseases_id_standard[i], ","))[j]
    id_source = unlist(strsplit(disease_id, "_"))[1]
    disease_name = str_trim(unlist(strsplit(biomarker_all$disease[i], ",|，"))[j])
    #in FDA label, remove the parent disease
    if (str_detect(disease_name, "/")){
      disease_name = unlist(strsplit(disease_name, "/"))[2]
    }
    
    disease_tb = rbind(disease_tb, data.frame(record_id, disease_name, disease_id, id_source))
  }
  
  #biomarker table
  #iterate every disease, nearly all records include only one disease
  for (j in 1:length(unlist(strsplit(biomarker_all$biomarker_ensembl_standard[i], ",")))){
    ensembl = str_trim(unlist(strsplit(biomarker_all$biomarker_ensembl_standard[i], ","))[j])
    name = str_trim(unlist(strsplit(biomarker_all$biomarker[i], ",|，"))[j])
    biomarker_type = str_trim(unlist(strsplit(biomarker_all$biomarker_type[i], ",|，"))[j])
    biomarker_direction = str_trim(unlist(strsplit(biomarker_all$biomarker_direction[i], ",|，"))[j])
    biomaker_name = paste(name, biomarker_type, biomarker_direction)
    
    biomarker_tb = rbind(biomarker_tb, data.frame(record_id, name, ensembl, biomarker_type, biomarker_direction, biomaker_name))  
  }
  
}


write.csv(biomarker_record_tb, "data/released/db/biomarker_record.csv", row.names = F, na = "\\N")
write.csv(biomarker_tb, "data/released/db/biomarker.csv", row.names = F, na = "\\N")
write.csv(drug_tb, "data/released/db/drug.csv", row.names = F, na = "\\N")
write.csv(disease_tb, "data/released/db/disease.csv", row.names = F, na = "\\N")

