#convert into json files
#example
'{
  "biolink:id": "FDA0001",
  "biolink:name": "FDAbiomarker1",
  "biolink:type": "biomarker",
  "curator": [
    {
      "biolink:name": "Ben Feng",
      "biolink:update_date": "2020-02-22T19:41:44.731Z",
      "biolink:comment": "" 
    }
  ],
  "biolink:has_drug": [
    {
      "biolink:id": [
        {
          "biolink:source_data_file": "Drugbank",
          "code": "DB01048",
          "biolink:versionOf": ""
        }
       "biolink:id": [
        {
          "biolink:source_data_file": "PubChem",
          "code": "29969962",
          "biolink:versionOf": ""
        }
      ],
      "biolink:name": "Abacavir",
      "biolink:type": "biolink:drug"
    },
  ],
    
  "has_disease": [
    {
      "biolink:id": [
        {
          "biolink:source_data_file": "EFO",
          "code": "EFO_0005741",
          "biolink:source_version": ""
        }
      ],
      "biolink:name": "Infectious disease/ADIS",
      "biolink:type": "biolink:disease",
      "biolink:comment": ""
    }
  ],
  "has_molecular_entity": [
    {
      "biolink:id": [
      {
         "biolink:source_data_file": "NCBI Entrez",
         "code": "ENSG00000234745"
       },
      "biolink:name": "HLA-B",
      "biolink:type": "polymorphism",
      "biolink:relation": "NA"
    }
    ],

  "biolink:has_evidence": [
    {
      "biolink:id": "",
      "biolink:EvidenceType": "FDA",
      "biolink:comment": ""
    }
  ]
}
'

library("rjson")
library("jsonlite")
library("stringr")

biomarker_all = read.csv("data/merged/biomarker_all.csv", stringsAsFactors = F)
biomarker_all = subset(biomarker_all, QC %in% c("pass"))

biomarker_lists = list()
for (i in 1:nrow(biomarker_all)){
  print(i)
  #has drug object
  drug_lists = list()
  for (j in 1:length(unlist(strsplit(biomarker_all$drug_drugbank_standard[i], ",")))){
      drugbank_id = unlist(strsplit(biomarker_all$drug_drugbank_standard[i], ","))[j]
      biolink__source_data_file1 = "Drugbank"
      code1 = drugbank_id
      biolink__versionOf1 = ""
  
      pubchem_id = unlist(strsplit(biomarker_all$drug_pubchem[i], ","))[j]
      biolink__source_data_file2 = "PubChem"
      code2 = pubchem_id
      biolink__versionOf2 = ""
  
      drug_name = str_trim(unlist(strsplit(biomarker_all$drug[i], ",|，"))[j])
      
      drug_lists[[j]] = (list(biolink__id = list(biolink__source_data_file = biolink__source_data_file1, code = code1, biolink__versionOf = biolink__versionOf1), 
           biolink__id = list(biolink__source_data_file = biolink__source_data_file2, code = code2, biolink__versionOf = biolink__versionOf2), 
           biolink__name = drug_name,  biolink__type = "biolink:drug"))
  }
  
  #has disease
  disease_lists = list()
  #iterate every disease, nearly all records include only one disease
  for (j in 1:length(unlist(strsplit(biomarker_all$diseases_id_standard[i], ",")))){
    disease_id = unlist(strsplit(biomarker_all$diseases_id_standard[i], ","))[j]
    source_id = unlist(strsplit(disease_id, "_"))[1]
    
    biolink__source_data_file = source_id
    code = disease_id
    biolink__versionOf = ""
    
    disease_name = str_trim(unlist(strsplit(biomarker_all$disease[i], ",|，"))[j])
    #in FDA label, remove the parent disease
    if (str_detect(disease_name, "/")){
      disease_name = unlist(strsplit(disease_name, "/"))[2]
    }
    
    disease_lists[[j]] = list(biolink__id = list(biolink__source_data_file = biolink__source_data_file, code = code, biolink__versionOf = biolink__versionOf), 
                            biolink__name = disease_name,  biolink__type = "biolink:disease")
  }
  
  #has molecular entity(me)
  ME_lists = list()
  #iterate every disease, nearly all records include only one disease
  for (j in 1:length(unlist(strsplit(biomarker_all$biomarker_ensembl_standard[i], ",")))){
    ME_id = unlist(strsplit(biomarker_all$biomarker_ensembl_standard[i], ","))[j]
    
    biolink__source_data_file = "ensembl"
    code = ME_id
    biolink__versionOf = ""
    
    ME_name = str_trim(unlist(strsplit(biomarker_all$biomarker[i], ",|，"))[j])
    ME_type = str_trim(unlist(strsplit(biomarker_all$biomarker_type[i], ",|，"))[j])
    ME_direction = str_trim(unlist(strsplit(biomarker_all$biomarker_direction[i], ",|，"))[j])
    biomaker_name = paste(ME_name, ME_type, ME_direction)
      
    ME_lists[[j]] = list(biolink__id = list(biolink__source_data_file = biolink__source_data_file, code = code, biolink__versionOf = biolink__versionOf), 
                              biomarker_name = biomaker_name, biomarker_type= ME_type, biomarker_direction = ME_direction,  biolink__name = ME_name, biolink__type = "biolink:molecular entity")
 }
  
  
  
  biomarker_lists[[i]] = list(biolink__id = biomarker_all$record_id[i], biolink__name = paste0(biomarker_all$drug[i], " treat ", biomarker_all$disease[i], " with ", biomarker_all$biomarker_description[i]),
           biolink__type = "biomarker", biomarker_term = biomarker_all$biomarker_description[i],
           curator = list(biolink__name = biomarker_all$curator[i], biolink__update_date = date(), biolink__comment = ""),
           biolink__has_drug = drug_lists, biolink__has_disease = disease_lists, biolink__has_molecular_entity = ME_lists, 
           biolink__has_evidence = list(biolink__id = biomarker_all$source_id[i], EvidenceType = biomarker_all$source[i], biolink__comment = ""))
}


json <- toJSON( biomarker_lists )
json_out = prettify(json)
json_out = str_replace_all(json_out, "__", ":")
write(json_out, file = "data/released/json/biomarkers.json")
