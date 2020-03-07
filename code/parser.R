#parse excels from curators
#provide a QC reports, QC: pass/failed

#####
args <- commandArgs(trailingOnly=T)
#main input file
input_file <- args[1]
output_file <- args[2]
#input_file = "Breast_cancer_CLINICALTRIAL_v7.xlsx"
#output_file = "Breast_cancer_CLINICALTRIAL_v7.csv"

###

library("readxl")
library("stringr")
library("rpubchem")
library("httr")
require("jsonlite")

get_drugbank_id <- function(drug, drugbank_dic){
  return(drugbank_dic$id[drugbank_dic$name == drug][1])
}

get_pubchem_cid <- function(drug){
  drug = str_replace_all(drug, " |\r|\n", "%20")
  url = paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/", drug, "/cids/txt?name_type=word")
  response = GET(url)
  if (status_code(response) == 200){
    cids = unlist(strsplit((content(response, as = "text", encoding = "UTF-8")), "\n"))
  }else{
    cids = NA
  }
  return(cids)
}

get_disease_id <- function(disease){
  disease = str_replace_all(disease, " |\r|\n", "%20")
  
  base = "https://platform-api.opentargets.io/v3/platform/"
  endpoint = "public/search"
  url = paste(base,endpoint,"?","q","=", disease,"&filter=disease", sep="")
  response = GET(url)
  if (status_code(response) == 200){
    return_dz = content(response)$data
    if (length(return_dz) > 0){
      match_score = return_dz[[1]]$score
      match_type = return_dz[[1]]$type
      match_id = return_dz[[1]]$id
      if (match_score > 10){
        return (list(match_id, match_type, match_score))
      }
    }
  }
  
  return(list(NA, NA, NA))
  
}

#the matching is not accurate, e.g., KI-67
get_target_id <- function(target){
  target = str_replace_all(target, " |\r|\n", "%20")
  
  base = "https://platform-api.opentargets.io/v3/platform/"
  endpoint = "public/search"
  url = paste(base,endpoint,"?","q","=", target,"&filter=target", sep="")
  response = GET(url)
  if (status_code(response) == 200){
    return_target = content(response)$data
    if (length(return_target) > 0){
      match_score = return_target[[1]]$score
      match_type = return_target[[1]]$type
      match_id = return_target[[1]]$id
      if (match_score > 100){
        return (list(match_id, match_type, match_score))
      }
    }
  }
   
  return(list(NA, NA, NA))
}

###
##prepare drugbank table
# drugbank = read.csv("drugbank vocabulary.csv", stringsAsFactors = F) #download from drugbank
# drugbank_synonyms = unique(c(toupper(unlist(strsplit(paste(drugbank$Synonyms, collapse = " | ") , " | "))), toupper(drugbank$Common.name)))
# 
# drugbank_reformat = data.frame()
# for (i in 1:nrow(drugbank)){
#   fields = unique(toupper(c(drugbank$Common.name[i], unlist(strsplit(drugbank$Synonyms[i], " \\| ")))))
#   drugbank_reformat = rbind(drugbank_reformat, data.frame(id = drugbank$DrugBank.ID[i], name = fields))
# }
# write.csv(drugbank_reformat, "drugbank_dic.csv")
############
drugbank_dic = read.csv("data/support/drugbank_dic.csv", stringsAsFactors = F)

###########
annotation =  data.frame(read_excel(input_file, sheet = 1))

for (i in 1:nrow(annotation)){
  print(i)

  drug_curation = annotation$Drug[i]
  #replace new line
  drug_curation = str_replace_all(drug_curation, "\n|\r", " ")
  drugs = toupper(unique(str_trim(unlist(strsplit(paste(as.character(drug_curation), collapse = ","), " AND | ,|，| and ")), side = "both")))
  
  #remove drug "()"
  drugs = sapply(drugs, function(drug) str_trim(unlist(strsplit(drug, "\\("))[1]))
  annotation$Drug[i] = paste(drugs, collapse = ", ")
  
  drugs_drugbank = paste(sapply(drugs, function(x) get_drugbank_id(x, drugbank_dic)), collapse = ",")
  drugs_pubchem = paste(sapply(drugs, function(x) get_pubchem_cid(x)[1]), collapse = ", ")

  biomarkers = toupper(unique(str_trim(unlist(strsplit(paste(as.character(annotation$Enrichment.biomarker[i]), collapse = ","), ",|，")), side = "both")))
  biomarkers_ensembl = paste(sapply(biomarkers, function(x) get_target_id(x)[1]), collapse = ", ")
  
  diseases = (str_trim(as.character(annotation$Disease[i]), side = "both"))
  #remove "/", keep the second, occurred in FDA labels
  diseases = sapply(diseases, function(disease) {
    if (str_detect(disease, "/")){
      unlist(strsplit(disease, "/"))[2]
    }else{
      disease
    }
  })
  annotation$Disease[i] = paste(diseases, collapse = ", ")
  diseases_EFO_MONDO = paste(sapply(diseases, function(x) get_disease_id(x)[1]), collapse = ", ")
  
  annotation$drug_drugbank_standard[i] = drugs_drugbank
  annotation$drug_pubchem[i] = drugs_pubchem
  annotation$biomarker_ensembl_standard[i] = biomarkers_ensembl
  annotation$diseases_EFO_MONDO_standard[i] = diseases_EFO_MONDO
  
  biomarker_direction = toupper((str_trim(unlist(strsplit(paste(as.character(annotation$Biomarker.relationship[i]), collapse = ","), ",|，")), side = "both")))
  biomarker_type = toupper((str_trim(unlist(strsplit(paste(as.character(annotation$Marker.type[i]), collapse = ","), ",|，")), side = "both")))
  biomarker_relation = toupper((str_trim(unlist(strsplit(paste(str_replace_all(as.character(annotation$Biomarker.logical.conditions[i]), "NA", ""), collapse = ","), ",|，")), side = "both")))
  
  if (length(biomarker_relation) == 1){
    if (biomarker_relation == "NA") biomarker_relation = NULL
  }
  
  if (length(biomarker_direction) != length(biomarker_type) | length(biomarker_direction) != length(biomarkers) | length(biomarkers) != (length(biomarker_relation) + 1)){
    term = "failed"
  }else{
    term = ""
    for (k in 1:length(biomarkers)){
      if (k == length(biomarkers)){
        term = paste(term, paste(biomarkers[k], biomarker_type[k], biomarker_direction[k]))
      }else{              
        term = paste(term, paste(biomarkers[k], biomarker_type[k], biomarker_direction[k], biomarker_relation[k]))
      }
    }
  }
  
  annotation$biomarker_term[i] = str_trim(term)
  
  #QC 
  #check drug mapping, assume at least map to either drugbank or pubchem
  QC = NULL
  if (sum(table(c(which((unlist(strsplit(drugs_drugbank, ","))) == "NA"), which((unlist(strsplit(drugs_pubchem, ","))) == "NA"))) > 1) > 0){
    QC = c(QC, "failed drug")
  }
  
  if (sum((unlist(strsplit(biomarkers_ensembl, ","))) == "NA") > 0){
    QC = c(QC, "failed biomarker")
  }

  if (is.na(annotation$Enrichment.biomarker[i]) | annotation$Enrichment.biomarker[i] == "absent" | length(annotation$Enrichment.biomarker[i]) == 0 ){
    QC = c(QC, "no biomarker")
  }
  
  if (sum((unlist(strsplit(diseases_EFO_MONDO, ","))) == "NA") > 0){
    QC = c(QC, "failed disease")
  }

  if (term == "failed"){
    QC = c(QC, "failed term")
  }  
  if (length(QC) == 0) QC = "pass"
  
  annotation$QC[i] = str_trim(paste(QC, collapse = ","))
  
}

write.csv(annotation, output_file)



