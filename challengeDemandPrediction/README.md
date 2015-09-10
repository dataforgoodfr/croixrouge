# Prédiction de la demande par catégorie de produit

Bienvenue dans ce challenge DataForGood pour la croix-rouge ! 

### Déroulement
Le challenge commence le 10/09/15. Un point intermédiaire sera fait lors du meetup du 13/10/15. Les trois meilleures 
équipes auront la chance de présenter leur modèle ce jour-là. Ce sera ensuite l'occasion pour vous de discuter et 
partager vos pistes d'améliorations, vos problèmes rencontrés, ... pour relancer la compétition pour encore un mois.
Que le meilleur gagne !!!

### Objectif

Un premier modèle (très simple) a été effectué prédisant la demande globale en fonction de la saisonnalité et de 
variable géographique. Ce modèle est disponible ici (lien à venir !), vous pourrez vous en inspirez !

L'objectif est de prédire pour chaque centre de la croix-rouge et chaque semaine le nombre de demandeurs (= nombre 
de venus fois la taille de leur foyer) par catégorie de produit.


### Données 
Pour ce faire, nous disposons des log bruts de la demande sur BigQuery dans la table SINVOICE_M. Un descriptif 
des colonnes est disponible [ici](https://github.com/dataforgoodfr/croixrouge/wiki/description-de-la-table-SINVOICE_M)

Si vous ne maitrisez pas bien le sql, cette requête vous permettra d'extraire les informations principales qui sont:
name|desc
---|---
id_centre|code du centre
dt|année-semaine
nBen_x|Nombre de bénéficiaires x semaine avant

```sql
SELECT
	id_centre,
	week,
	nBen,
	LAG(nBen,1) OVER (PARTITION BY id_centre ORDER BY week ASC) nBen_1,
	LAG(nBen,2) OVER (PARTITION BY id_centre ORDER BY week ASC) nBen_2,
	LAG(nBen,3) OVER (PARTITION BY id_centre ORDER BY week ASC) nBen_3,
	LAG(nBen,4) OVER (PARTITION BY id_centre ORDER BY week ASC) nBen_4,
	LAG(nBen,5) OVER (PARTITION BY id_centre ORDER BY week ASC) nBen_5
FROM
	(
	SELECT
		id_centre,
		week,
		SUM(sizeFoyer) nBen
	FROM
		(
		SELECT
			FCY id_centre,
			DATE(UTC_USEC_TO_WEEK(PARSE_UTC_USEC(
		  			concat("20",substr(CREDAT,7,2),'-',substr(CREDAT,4,2),'-',substr(CREDAT,0,2))),0)/1000000) week,
			BPR benef,
			INTEGER(YNBR) sizeFoyer,

		FROM
			[stojou.SINVOICE_M]
		GROUP BY 1,2,3,4
		)
	GROUP BY 1,2
	)
```

De plus, pour obtenir des variables liées à la géolocalisation des centres [cette table](https://github.com/dataforgoodfr/croixrouge/blob/master/data/dim_u2a_ville.csv)
vous permettra de joindre ses infos. 

Enfin n'hésitez pas à utiliser des données tierces comme des données INSEE pour améliorer votre modèle. 



