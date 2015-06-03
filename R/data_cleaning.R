require(data.table)


### DIM_STR_DEPT
#delete the empty DIM_STR_DEPT table
aida_agg[["DIM_STR_DEPT"]] <- NULL

### DIM_DATE
# delete the following unnecessary rows in DIM_DATE
# NUM_INV_MOIS
# LB_MOIS
# NUM_INV_TRIM
# LB_TRIM
# LIB_ANNEE
aida_agg[["DIM_DATE"]][, c("NUM_INV_MOIS","LB_MOIS","NUM_INV_TRIM","LB_TRIM", "LIB_ANNEE"):=NULL]


### OUTLIERS IN STO_FOUR_ORI and ART_DIS_SURFAMILLE
# remove outliers in tables STO_FOUR_ORI & ART_DIS_SURFAMILLE. No apparent outliers in ART_DIS_FAMILLE
# rule: remove all rows zhere QTE_NETTE or POIDS_NET is > 1e7
aida_agg[["STO_FOUR_ORI"]] <- aida_agg[["STO_FOUR_ORI"]][aida_agg[["STO_FOUR_ORI"]]$QTE_NETTE < 1e7 & aida_agg[["STO_FOUR_ORI"]]$POIDS_NET < 1e7,]
aida_agg[["ART_DIS_SURFAMILLE"]] <- aida_agg[["ART_DIS_SURFAMILLE"]][aida_agg[["ART_DIS_SURFAMILLE"]]$QTE_NETTE < 1e7 & aida_agg[["ART_DIS_SURFAMILLE"]]$POIDS_NET < 1e7,]



### NAs
# look for all the tables with NAs
search_nas(aida_agg)

ginfo(aida_agg[["BEN_DUREE_DROIT"]])
ginfo(aida_agg[["DIM_HIER_STR"]])
ginfo(aida_agg[["DIM_U2A"]])

aida_agg[["BEN_DUREE_DROIT"]][!complete.cases(aida_agg[["BEN_DUREE_DROIT"]])]
aida_agg[["DIM_HIER_STR"]][!complete.cases(aida_agg[["DIM_HIER_STR"]])]
aida_agg[["DIM_U2A"]][!complete.cases(aida_agg[["DIM_U2A"]])]

colinfo(aida_agg[["BEN_DUREE_DROIT"]])
colinfo(aida_agg[["DIM_HIER_STR"]])
colinfo(aida_agg[["DIM_U2A"]])

### DUPLICATES
#look for all the tables with duplicates
search_dup(aida_agg)

### REGLER PB ENCODAGE
print("reglage des problemes d'encodage")
for(nm in names(aida_agg))
  aida_agg[[nm]] <- solve_encoding(aida_agg[[nm]])

### STO_FOUR_ORI
#remove duplicates from the table "STO_FOUR_ORI"
aida_agg[["STO_FOUR_ORI"]] <- aida_agg[["STO_FOUR_ORI"]][!duplicated(aida_agg[["STO_FOUR_ORI"]])]
#incoherence avec le Centre distribution Pont de Beauvoisin ==> actions a prendre ?
aida_agg[["DIM_U2A"]][aida_agg[["DIM_U2A"]]$LB_U2A == "Centre distribution Pont de Beauvoisin"]
#repertorier les centres non labellises: "A DEFINIR"
cdu2a_non_lb = aida_agg[["DIM_U2A"]][sapply(aida_agg[["DIM_U2A"]]$LB_U2A, FUN = function(x){substring(x,1,9) == "A DEFINIR"} ) ]


### Look for duplicates in 2 similar data tables, remove them and create a new unified data table
print("concat similar tables")

#BEN_CHARGES_FOURCH & BEN_CHARGES_FOURCH_N
print("BEN_CHARGES_FOURCH & BEN_CHARGES_FOURCH_N")
aida_agg[["BEN_CHARGES_FOURCH"]] <- search_dup(aida_agg[["BEN_CHARGES_FOURCH"]], aida_agg[["BEN_CHARGES_FOURCH_N"]], remove = T)
aida_agg[["BEN_CHARGES_FOURCH_N"]] <- NULL

#BEN_CHARGES_NB_FICHES & BEN_CHARGES_NB_FICHES_N
print("BEN_CHARGES_NB_FICHES & BEN_CHARGES_NB_FICHES_N")
aida_agg[["BEN_CHARGES_NB_FICHES"]] <- search_dup(aida_agg[["BEN_CHARGES_NB_FICHES"]], aida_agg[["BEN_CHARGES_NB_FICHES_N"]], remove = T)
aida_agg[["BEN_CHARGES_NB_FICHES_N"]] <- NULL

#BEN_DUREE_FOYER & BEN_DUREE_FOYER_N
print("BEN_DUREE_FOYER & BEN_DUREE_FOYER_N")
aida_agg[["BEN_DUREE_FOYER"]] <- search_dup(aida_agg[["BEN_DUREE_FOYER"]], aida_agg[["BEN_DUREE_FOYER_N"]], remove = T)
aida_agg[["BEN_DUREE_FOYER_N"]] <- NULL

#BEN_REVENUS_FOURCH & BEN_REVENUS_FOURCH_N & BEN_REVENUS_FOURCH_NEW
# !! BEN_REVENUS_FOURCH has different columns from the other two tables.
# we therefore concatenate only BEN_REVENUS_FOURCH_N & BEN_REVENUS_FOURCH_NEW
# we delete BEN_REVENUS_FOURCH_N
print("BEN_REVENUS_FOURCH & BEN_REVENUS_FOURCH_N & BEN_REVENUS_FOURCH_NEW")
aida_agg[["BEN_REVENUS_FOURCH_NEW"]] <- search_dup(aida_agg[["BEN_REVENUS_FOURCH_N"]], aida_agg[["BEN_REVENUS_FOURCH_NEW"]], remove = T)
aida_agg[["BEN_REVENUS_FOURCH_N"]] <- NULL


#BEN_REVENUS_NB_FICHES & BEN_REVENUS_NB_FICHES_N
print("BEN_REVENUS_NB_FICHES & BEN_REVENUS_NB_FICHES_N")
aida_agg[["BEN_REVENUS_NB_FICHES"]] <- search_dup(aida_agg[["BEN_REVENUS_NB_FICHES"]], aida_agg[["BEN_REVENUS_NB_FICHES_N"]], remove = T)
aida_agg[["BEN_REVENUS_NB_FICHES_N"]] <- NULL

#BEN_SEXE_AYANTDROIT & BEN_SEXE_AYANTDROIT_N
print("BEN_SEXE_AYANTDROIT & BEN_SEXE_AYANTDROIT_N")
aida_agg[["BEN_SEXE_AYANTDROIT"]] <- search_dup(aida_agg[["BEN_SEXE_AYANTDROIT"]], aida_agg[["BEN_SEXE_AYANTDROIT_N"]], remove = T)
aida_agg[["BEN_SEXE_AYANTDROIT_N"]] <- NULL

#BEN_SEXE_CHEFFOYER & BEN_SEXE_CHEFFOYER_N
print("BEN_SEXE_CHEFFOYER & BEN_SEXE_CHEFFOYER_N")
aida_agg[["BEN_SEXE_CHEFFOYER"]] <- search_dup(aida_agg[["BEN_SEXE_CHEFFOYER"]], aida_agg[["BEN_SEXE_CHEFFOYER_N"]], remove = T)
aida_agg[["BEN_SEXE_CHEFFOYER_N"]] <- NULL

#BEN_STATUT_FOYER & BEN_STATUT_FOYER_N
print("BEN_STATUT_FOYER & BEN_STATUT_FOYER_N")
aida_agg[["BEN_STATUT_FOYER"]] <- search_dup(aida_agg[["BEN_STATUT_FOYER"]], aida_agg[["BEN_STATUT_FOYER_N"]], remove = T)
aida_agg[["BEN_STATUT_FOYER_N"]] <- NULL

#BEN_TYPO_FOYER & BEN_TYPO_FOYER_N
print("BEN_TYPO_FOYER & BEN_TYPO_FOYER_N")
aida_agg[["BEN_TYPO_FOYER"]] <- search_dup(aida_agg[["BEN_TYPO_FOYER"]], aida_agg[["BEN_TYPO_FOYER_N"]], remove = T)
aida_agg[["BEN_TYPO_FOYER_N"]] <- NULL

#BEN_TYP_FOYER & BEN_TYP_FOYER_N
print("BEN_TYP_FOYER & BEN_TYP_FOYER_N")
aida_agg[["BEN_TYP_FOYER"]] <- search_dup(aida_agg[["BEN_TYP_FOYER"]], aida_agg[["BEN_TYP_FOYER_N"]], remove = T)
aida_agg[["BEN_TYP_FOYER_N"]] <- NULL

### Remove the DIM_SEXE table and replace the code by "H", "F", "HF"
tbles = check_col(aida_agg, "CD_SEXE")[!(check_col(aida_agg, "CD_SEXE") %in% "DIM_SEXE")]
for(nm in tbles)
{
  aida_agg[[nm]][, "SEXE":=as.character(sapply(.SD, 
                                  FUN = function(x){sapply(x, FUN = function(y) {as.character(y);if(y == 0) "HF" else if(y == 1) "H" else if(y == 2) "F"})})), .SDcols = "CD_SEXE"]
  print(class(aida_agg[[nm]]$SEXE))
  aida_agg[[nm]][, CD_SEXE:=NULL]
}
aida_agg[["DIM_SEXE"]] <- NULL

### "DIM_TYPO_FOYER_BEN" --> delete the first category which is irrelevant
check_col(aida_agg, "CD_TYPO_FOYER_BEN")
aida_agg[["DIM_TYPO_FOYER_BEN"]] <- aida_agg[["DIM_TYPO_FOYER_BEN"]][2:nrow(aida_agg[["DIM_TYPO_FOYER_BEN"]]), ]