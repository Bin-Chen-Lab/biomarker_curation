#collect breast cancer samples

library(cgdsr)
library(stringr)


mycgds = CGDS("https://www.cbioportal.org/")
# Get list of cancer studies at server
a = getCancerStudies(mycgds)

# Get available case lists (collection of samples) for a given cancer study
mycancerstudies = getCancerStudies(mycgds)[,1]
mycancerstudy = "brca_tcga"
mycaselist = getCaseLists(mycgds, mycancerstudy)[1,1]
myclinicaldata = getClinicalData(mycgds,mycaselist)

patient_id = sapply(rownames(myclinicaldata), function(x) str_replace_all(x, "\\.", "-"))

patient_features = data.frame(patient_id, HER2 = tolower(myclinicaldata$HER2_FISH_STATUS),
                              ESR1 = tolower(myclinicaldata$ER_STATUS_BY_IHC), PR = tolower(myclinicaldata$PR_STATUS_BY_IHC), OS_MONTHS =  myclinicaldata$OS_MONTHS, OS_STATUS = myclinicaldata$OS_STATUS)

write.csv(patient_features, "data/support/patient_brca_tcga.csv")
