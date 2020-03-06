#merge all annotation into one single file
setwd("~/Documents/stanford/grant/2019/ot2/work/")

###
#column description
#

data_all = NULL

data_v0 = read.csv("FDA-drug&biomarkers-v8_Ben.csv")
data_v1 = data_v0[, c("Drug", "drug_drugbank_standard", "drug_pubchem", "Enrichment.biomarker", "biomarker_ensembl_standard",
                  "Marker.type", "Biomarker.relationship", "Biomarker.logical.conditions", "biomarker_term",
                  "Disease",  "diseases_EFO_MONDO_standard","Targets" )  ]
data_v1$curator = "Ben"
data_v1$raw_table = "FDA-drug&biomarkers-v8.xlsx"
data_v1$source = "FDA"
data_v1$source_id = "NA"
data_all = rbind(data_all, data_v1)

data_v0 = read.csv("breast_cancer_trials_Ben.csv")
data_v1 = data_v0[, c("Drug", "drug_drugbank_standard", "drug_pubchem", "Enrichment.biomarker", "biomarker_ensembl_standard",
                  "Marker.type", "Biomarker.relationship", "Biomarker.logical.conditions", "biomarker_term",
                  "Disease",  "diseases_EFO_MONDO_standard","Targets" )  ]
data_v1$curator = "Ben"
data_v1$raw_table = "Breast_cancer_CLINICALTRIAL_v7.xlsx"
data_v1$source = "clinicaltrials.gov"
data_v1$source_id = data_v0$ClinicalTrials.gov.reference
data_all = rbind(data_all, data_v1)

data_v0 = read.csv("Breast_Cancer_NCT04194684.csv")
data_v1 = data_v0[, c("Drug", "drug_drugbank_standard", "drug_pubchem", "Enrichment.biomarker", "biomarker_ensembl_standard",
                      "Marker.type", "Biomarker.relationship", "Biomarker.logical.conditions", "biomarker_term",
                      "Disease",  "diseases_EFO_MONDO_standard","Targets" )  ]
data_v1$curator = "Tyler"
data_v1$raw_table = "Breast Cancer (LT NCT04194684, 1-50)_tyler.xlsx"
data_v1$source = "clinicaltrials.gov"
data_v1$source_id = data_v0$clinicaltrials.gov.reference
data_all = rbind(data_all, data_v1)


data_v0 = read.csv("Breast_Cancer_NCT04001621.csv")
data_v1 = data_v0[, c("Drug", "drug_drugbank_standard", "drug_pubchem", "Enrichment.biomarker", "biomarker_ensembl_standard",
                      "Marker.type", "Biomarker.relationship", "Biomarker.logical.conditions", "biomarker_term",
                      "Disease",  "diseases_EFO_MONDO_standard","Targets" )  ]
data_v1$curator = "Austin"
data_v1$raw_table = "Breast Cancer (LT NCT04001621, 1-50)_austin.xlsx"
data_v1$source = "clinicaltrials.gov"
data_v1$source_id = data_v0$clinicaltrials.gov.reference
data_all = rbind(data_all, data_v1)

data_all$ID = c(1:nrow(data_all))

colnames(data_all) = c("drug", "drug_drugbank_standard", "drug_pubchem", "biomarker", "biomarker_ensembl_standard",
                       "biomarker_type", "biomarker_direction", "biomarker_relations", "biomarker_description",
                       "disease",  "diseases_id_standard","drug_targets", "curator", "raw_table", "source", "source_id" ) 

write.csv(data_all, "biomarker_all.csv")
#
#drug: drug name directly taken from the raw text
#drug_drugbank_standard: drug drugbank ID; NA: means unmapped; The drug that has not been approved may not have drugbank id.
#drug_pubchem: drug PubChem Compound ID; if the drug is a biological entity, it may have not PubChem Compound ID
#biomarker: biomarker names taken from the raw text; mostly are related to gene, occationally related to protein target (antibody name), metabolite or other entities
#biomarker_ensembl_standard: biomarker ensembl id (mapped through open target APIs), some mappings might not be accurate as opentarget using a similarity matching; non-gene-biomarkers may not have ensembl id
#biomarker_type: ~16 biomarker types were summarized such as gene expression, protein expression, mutation.
#biomarker_direction: postive or negative. For mutation, positive means the patient should harbor this mutation; for protein expression, positive means the patient should have highly expressed protein.
#biomarker_relations: The relation between multiple biomarkers. AND: patients should present both biomarkers; OR: patients present either of the biomarkers
#biomarker_description: a summary of the biomarker description ( a combination of biomarker name, type, direction, and relations). It should be more understandable.
#disease: disease taken from the raw text
#diseases_id_standard: disease ID mapped to EFO/MONDO(Monarch Disease) via opentarget API. Similarity matching was performed, only the top disease was selected; many of the mappings are problematic so should be used in caution.
#drug_targets: drug targets taken from the raw text. We only add the targets mentioned in the text.
#curator
#raw_table: raw_table provided by the curator
#source: FDA, clinicaltrials.gov or PubMed
#source ID: FDA source IDs are the same as taken from the same website. clinicaltrials.gov: clinical trial ID, PubMed: PubMed ID



