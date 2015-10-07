# Prédiction de la demande par catégorie de produits

Bienvenue dans le premier challenge DataForGood pour la Croix-Rouge Française ! 

### Déroulement
Le challenge commence le 10/09/15. Un point intermédiaire sera fait lors du meetup du 20/10/15. Les trois meilleures équipes auront la chance de présenter leur approche et modèle ce jour-là. Ce sera ensuite l'occasion pour vous de discuter et partager vos pistes d'améliorations, vos problèmes rencontrés, ... pour relancer la compétition pour un mois de plus. Que le meilleur gagne !

### Comment participer ? 

1 - Rejoignez la discussion DataForGood sur Slack (channel croix-rouge)
2 - Postez votre code, sous la forme NOM_EQUIPE.zip. 
3 - Nous évaluons la performance de votre approche et mettons votre code sur Github. La mesure d'erreur utilisée sera le RMSE ! 

N'hésitez pas à contacter @bettina ou @romainwarlop sur Slack si vous rencontrez le moindre problème.

### Objectif

Un premier modèle (très simple) a été présenté lors du dernier meetup. Celui-ci prédit par centre croix-rouge/semaine la demande globale en fonction de la saisonnalité et de variables géographiques.

L'objectif de ce nouveau challenge est d'augmenter la granularité: il s'agit de prédire par centre de la Croix-Rouge et par semaine, le nombre de bénéficiaires (= nombre de venus x taille de leur foyer) par CATEGORIE DE PRODUIT.


### Données 
Pour ce faire, nous disposons des log bruts de la distribution alimentaire de la Croix Rouge sur BigQuery dans la table SINVOICE_M. Un descriptif 
des colonnes est disponible [ici](https://github.com/dataforgoodfr/croixrouge/wiki/description-de-la-table-SINVOICE_M)

Nous avons créé une table (challengeDP) avec les informations principales. Ci-dessous la requête qui nous a permis d'avoir cette table si vous souhaitez l'adapter pour ajouter des variables.

name|desc
---|---
id_centre|code du centre
dt|année-semaine
nBen_x|Nombre de bénéficiaires x semaine avant

```sql
SELECT
	id_centre, week, cat, SUM(sizeFoyer) nBen
FROM
	(
	SELECT
		c.id_centre id_centre,
		c.week week,
		c.sizeFoyer sizeFoyer,
		d.cat2 cat
	FROM
		(
		SELECT
		    a.FCY id_centre,
		    DATE(UTC_USEC_TO_WEEK(PARSE_UTC_USEC(
		            concat("20",substr(a.CREDAT,7,2),'-',substr(a.CREDAT,4,2),'-',substr(a.CREDAT,0,2))),0)/1000000) week,
		    a.BPR benef,
		    INTEGER(a.YNBR) sizeFoyer,
		    b.ITMREF_0 itemref
		FROM 
			[stojou.SINVOICE_M] a
		LEFT JOIN EACH
			[stojou.stojou] b
		ON 
			a.NUM = b.VCRNUM_0
		) c
	LEFT JOIN EACH
		[stojou.itmcorres] d
	ON 
		c.itemref=d.itemref
	)
GROUP BY 1,2,3
```

Nous vous conseillons les librairies suivantes pour récupérer les données de BigQuery : 

- R - https://github.com/hadley/bigrquery
- Python - http://pandas.pydata.org/pandas-docs/stable/io.html#io-bigquery

Un exemple en langage R :
```
install.packages(bigrquery)
library(bigrquery)
project = 'croix-rouge-92715'
request = "SELECT ce que je veux FROM [stojou.SINVOICE_M]"
data <- query_exec(request,project=project,max_pages=Inf)
# ici R vous colle un lien dans la console, il faut le copier coller dans votre nagivateur web. 
# Après acceptation vous obtenez un mot de passe qu'il faut copier coller dans R
# Enfin R demande si vous voulez sauvegarder ce mot de passe. Dîtes oui si vous voulez pas refaire ça 
# à chaque fois (peut-être qu'il demande ça avant le lien je me souviens plus trop ...)
# Et voilà vous avez les données
```

De plus, pour obtenir des variables liées à la géolocalisation des centres [cette table](https://github.com/dataforgoodfr/croixrouge/blob/master/data/dim_u2a_ville.csv)
vous permettra de faire la jointure. 

Enfin n'hésitez pas à utiliser des données tierces comme des données INSEE par exemple pour améliorer votre modèle.

À vos claviers !



