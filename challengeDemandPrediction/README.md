# Prédiction de la demande par catégorie de produit

// DRAFT //

Bienvenue dans ce challenge DataForGood pour la croix-rouge ! 

### Déroulement
Le challenge commence le 10/09/15. Un point intermédiaire sera fait lors du meetup du 13/10/15. Les trois meilleures équipes auront la chance de présenter leur modèle ce jour-là. Ce sera ensuite l'occasion pour vous de discuter et partager vos pistes d'améliorations, vos problèmes rencontrés, ... pour relancer la compétition pour un mois de plus. Que le meilleur gagne !!!

### Comment participer ? 

La première étape est de rejoindre la discussion DataForGood sur slack et de suivre le groupe de discussion cr-challenge. 

Une fois votre code prêt dans le language de votre choix, postez sur cette conversation un dossier NOM_EQUIPE.zip 
contenant l'ensemble des codes permettant de reproduire votre modèle. Nous nous assurerons de l'évaluation de la 
performance, de sa mise a disposition dans ce dossier github et du classement des équipes. 

La mesure d'erreur utilisée sera le RMSE ! 

N'hésitez pas à contacter @bettina ou @romainwarlop sur slack si vous rencontrez le moindre problème.

### Objectif

Un premier modèle (très simple) a été présenté lors du dernier meetup. Celui-ci prédit par centre croix-rouge/semaine la demande globale en fonction de la saisonnalité et de variables géographiques. Ce modèle est disponible ici (lien à venir !), vous pouvez vous en inspirez !

L'objectif de ce nouveau challenge est d'augmenter la granularité: il s'agit de prédire pour chaque centre de la croix-rouge et chaque semaine le nombre de demandeurs (= nombre de venus fois la taille de leur foyer) par CATEGORIE DE PRODUIT.


### Données 
Pour ce faire, nous disposons des log bruts de la demande sur BigQuery dans la table SINVOICE_M. Un descriptif 
des colonnes est disponible [ici](https://github.com/dataforgoodfr/croixrouge/wiki/description-de-la-table-SINVOICE_M)

Si vous ne maitrisez pas bien le sql, cette requête vous permettra d'extraire les informations principales qui sont (la catégorie de produit est à rajouter):
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
vous permettra de faire la jointure. 

Enfin n'hésitez pas à utiliser des données tierces comme des données INSEE par exemple pour améliorer votre modèle.

À vos claviers !



