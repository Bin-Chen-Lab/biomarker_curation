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

biomarker_all = read.csv("biomarker_all.csv", stringsAsFactors = F)

biomarker_lists = list()
for (i in 1:nrow(biomarker_all)){
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
  
      drug_name = str_trim(unlist(strsplit(biomarker_all$Drug[i], ",|，"))[j])
      
      drug_lists[[j]] = (list(biolink__id = list(biolink__source_data_file = biolink__source_data_file1, code = code1, biolink__versionOf = biolink__versionOf1), 
           biolink__id = list(biolink__source_data_file = biolink__source_data_file2, code = code2, biolink__versionOf = biolink__versionOf2), 
           biolink__name = drug_name,  biolink__type = "biolink:drug"))
  }
  
  biomarker_lists[[i]] = list(biolink__id = biomarker_all$ID[i], biolink__name = paste0(biomarker_all$Drug[i], " treat ", biomarker_all$Disease[i], " with ", biomarker_all$biomarker_term[i]),
           biolink__type = "biomarker", 
           curator = list(biolink__name = biomarker_all$curator[i], biolink__update_date = date(), biolink__comment = ""),
           biolink_has_drug = drug_lists)
}


json <- toJSON( biomarker_lists )
json_out = prettify(json)
json_out = str_replace_all(json_out, "__", ":")
write(json_out, file = "biomarker_json.json")
