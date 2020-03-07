#mapper patient 2 biomarker records
biomarker_records = read.csv("data/merged/biomarker_all.csv", stringsAsFactors = F)

patient_features = read.csv("data/support/patient_brca_tcga.csv", stringsAsFactors = F)

patient_biomarker = NULL

#map breast cancer tcga
biomarker_records = biomarker_records[biomarker_records$diseases_id_standard == "MONDO_0007254", ]
for (i in 1:nrow(biomarker_records)){
  record_id = biomarker_records$record_id[i]
  biomarker_types = unlist(strsplit(biomarker_records$biomarker_type[i], ",|，"))
  biomarker_directions = unlist(strsplit(biomarker_records$biomarker_direction[i], ",|，"))
  biomarkers = unlist(strsplit(biomarker_records$biomarker[i], ",|，"))
  biomarker_relations = unlist(strsplit(biomarker_records$biomarker_relations[i], ",|，"))
  
  candidates = NULL
  for (j in 1:length(biomarkers)){
    if (str_trim(biomarkers[j] ) == "ESR1"){
        candidatesX = patient_features$patient_id[patient_features$ESR1 ==  biomarker_directions[j]]
    }
    if (str_trim(biomarkers[j]) %in% c("HER2", "ERBB2")) {
      candidatesX = patient_features$patient_id[patient_features$HER2 ==  biomarker_directions[j]]
    }
    if (str_trim(biomarkers[j]) == "PR"){
      candidatesX = patient_features$patient_id[patient_features$PR ==  biomarker_directions[j]]
    }
    
    if (length(candidates) == 0) {
      candidates = candidatesX
    }else if (j <= length(biomarker_relations)){
      if (biomarker_relations[j] == "AND"){
        candidates = intersect(candidates, candidatesX)
      }else{
        candidates = unique(c(candidates, candidatesX))
      }
    }
  }
  
  if (length(candidates) > 0){
   patient_biomarker = rbind(patient_biomarker, data.frame(record_id, patient_id = candidates))
  }
}

write.csv(patient_biomarker, "data/released/db/patient.csv", row.names = F)
