---
title: "Construction de la cascade <br/> des coûts sous R"
author: "Ismaila"
date: "20 février 2018"
output: 
  html_document: 
  #prettydoc::html_pretty:
    theme: cosmo
    #css: style.css
    highlight: pygments
    self_contained: yes
    code_folding: hide
    toc_float: true
    toc: yes
    toc_depth: 6
    #toc_float: no
---


<!--html_preserve--><img src="data:image/png;base64,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" alt="logo" style="position:absolute; top:0; right:0; padding:10px;"/><!--/html_preserve-->

---



```r
library(tidyverse)
library(ggplot2)
library(readr)
library(stringi)
library(knitr)
library(kableExtra)
library(data.table)
library(microbenchmark)
#library(plotly)

# Définition du chemin de travail
setwd("W:/01 - Projets/Cascade des coûts/Cascade")
```


# Introduction
Ce document explique les différentes étapes de la construction de la cascade des coûts. Pour faciliter l'explication du processus, nous avons découpé les activités en 3 classes :

* `CDO`: Ce sont les charges directes opérationnelles. Elles représentent les activités sur lesquelles les charges des autres activités doivent être ventilées. Elles sont indexées par les codes 1 à 25.
* `CIO` : Charges indirectes opérationnelles. Ce sont des charges à ventiler selon des codes temps. Elles sont indexées par les codes 26 à 35.
* `CSS` : Charges de Structures et de support. Ce sont les autres charges qui se ventilent selon les clés temps ou les clés au taux de frais ou encore les deux. Elles sont indexées par les codes 36 à 61.

# Importation des fichiers de paramétrage
Dans un premier temps, on importe les fichiers de paramétrage qui seront utilisés dans le calcul des clés de répartition des charges. Ici, nous importons les fichiers suivant :


* Le paramétrage pour le calcul des clés temps
* Le paramétrage des marquages d'activités dans lequel tout se repose sur les codes activités
* Le paramétrage pour la construction des clés de taux de frais qui sont des clés qui se baseront sur les charges directes et les charges issues de la ventilation des coûts via les clés temps.
* Les données brutes : Pour ces données, dans un premier temps nous avons utilisé les charges après retraitement. Ceci sera corrigé après les vérifications pour stabiliser l'outil. À noter que ces données pour faciliter le traitement dans l'outil seront au format csv.


```r
################################
# Le paramétrage des clés temps#
################################

param_temps <- read_delim("param_temps.csv", 
    ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-2"), 
    trim_ws = TRUE)

param_temps <- param_temps %>%
    mutate(temps_min = if_else(is.na(temps_min), 0, temps_min))%>%
  filter(Code_Activite>0)

param_tf <- read_delim("param_tf.csv", 
    ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-2"), 
    trim_ws = TRUE)

param_type_cle <- read_delim("param_type_cle.csv", 
    ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-2"), 
    trim_ws = TRUE)

marquage <- read_delim("marquage.csv", 
    ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-2"), 
    trim_ws = TRUE)



data <- read_delim("data.csv", 
    ";", escape_double = FALSE, locale = locale(encoding = "ISO-8859-2"), 
    trim_ws = TRUE)

#Valeurs en dur pour le traitement activité 30
charge_heberge_facteur=12537410.3015909


# Formation
prestation_formation=5308121 # A soustraire des charge du code 41
Formation_LCB=12625761 #??? A allouer à l'activité 7

#parametrage des listes 
CDO =c('code_1','code_2','code_3','code_4','code_5','code_6','code_7','code_8','code_9','code_10',
'code_11','code_12','code_13','code_14','code_15','code_16','code_17','code_18','code_19','code_20','code_21',
'code_22','code_23','code_24','code_25')

CIO_int<-c('Code_Activite','weight_code_26','weight_code_27','weight_code_28','weight_code_29',
                           'weight_code_30',
                           'weight_code_31','weight_code_32','weight_code_33','weight_code_34','weight_code_35')
```

# Marquage de la base de charges pilotées

Le réseau envoie une base de charges qui comporte un certain nombre d'élements. Cette base de charge est préalablement marquée par le réseau grâce au `CAA`, le `TCA` et la `rubrique Corp`.

Le marquage de la base des charges consiste à associer à chaque opération le code activité correspondant. Pour ce faire, nous avons besoin de 4 éléments qui nous permettent de construire un identifiant. Ces 4 éléments sont la concaténation de :

* Le code du processus cascade qui est au format `PCXXX` X représentant un chiffre
* Le code de l'activité métier qui est au format `AMXXXX`
* Le code de l'activité Cascade qui est au format `ACXX`
* Le code du label Analytique qui est au format `AAAAAA` A représentant une lettre.

Ces 4 éléments sont issus d'un marquage qui est réalisé par le réseau en se basant sur le `CAA`, le `TCA` et la `rubrique Corp`. 

<center>
![](marquage_1.PNG)
</center>

Grâce à ces 4 éléments, on construit la clé au format **`PCXXXAMXXXXACXXAAAAAA`**. De là, nous associons à chaque identifiant l'activité correspondante.

<center>
![](marquage_2.PNG)
</center>

# Construction des clés 
Nous allons expliciter ici la construction des clés temps et des clés au taux de frais.


## Construction des clés temps pour les activités à ventiler

### Méthodologie
Dans cette partie, nous construirons les clés temps et par la même occasion les coûts intermédiaires ventilés grâce à ces clés temps.
Nous partons de la matrice de paramétrage qui a été importée ci-haut.
![](param_temps.PNG)
Le fichier de paramétrage contient les éléments suivants :

* Les 2 premières colonnes décrivent les codes et les libellés pour lesquels on doit calculer les clés temps. Les codes en ligne contiennent à la fois des activités opérationnelles COD, mais aussi les autres activités qui doivent être ventilées avec les clés temps.
* la 3 ème colonne décrit les temps agent alloué à l'activité
* les autres colonnes décrivent COI et les CSS qui doivent être ventilées sur les activités en lignes. Ainsi si pour une colonne on met 'o' pour une activité cela signifie que les charges de cette activité doivent être ventilées sur l'activité en ligne correspondante.

Cette façon de faire, suppose donc que nous devons connaître en amont les charges des différentes activités qui sont en colonne. Cette information se trouve dans la base de charge avec la colonne **Ch_AP_Ret** qui représente les charges après retraitement.
Essayons de formaliser mathématiquement le calcul des clés temps.


* Soit $K=(1,...,k...,K)$ l'ensemble des activités sur lesquels on doit calculer des clés temps
* Soit $J=(1,...,j...,J)$ l'ensemble des activités pour lesquels on doit ventiler des charges.
* Soit $T_{k}$ le temps alloué à l'opération $k$
* Soit $\mathbb{1}_{k}(o)$ la fonction indicatrice qui indique si une activité de l'ensemble $J$ doit être ventilé sur l'activité $k$ de l'ensemble $K$. Cette fonction représente le fichier de paramétrage avec les options "o"
* Soit $W_{k}^{j}$ la clé temps de l'activité $j$ à ventiler sur l'activité $k$ 

$$ W_{k}^{j}=\frac{T_{k}*\mathbb{1}_{k}(o) }{\sum_{i \in (\mathbb{1}_{k}(o)} \mathbb{1}_{i}(o)*T_{i} }$$
Traduit litéralement, cette formule signifie que le poids d'une activité est égal au rapport de son temps sur la somme des temps des activité sur laquelle la charge doit être ventilée.

Ce poids est appliqué à la charge après traitement des opérations à ventiler. Soit $Charge_{k}^{j}$ la charge de l'opération $j$ à ventiler sur l'opération $k$, nous aurons donc :
$$ChargeTA_{k}^{j}=Charge_{k}^{j}*W_{k}^{j}$$




```r
# Jointure de la table des données avec la table de marquage et création de la variable de code
data<-data %>% left_join(marquage[,9:13])%>%
              mutate(code=stri_replace_all_fixed(paste('code_',Code_manuel), " ", ""),
                     Ch_AP_Ret=ifelse(is.na(Ch_AP_Ret),0,Ch_AP_Ret))%>%
  filter(is.na(Code_manuel)==0)

# Calcul des charges intermédiaires pour la construction des taux de frais
#Cette table sera utilisée dans la suite pour le calcul des clés au taux de frais
Charges_for_TA<-data%>% 
    group_by(code)%>%
     summarise(charges_TA=sum(Ch_AP_Ret))

a<-as.data.frame(t(Charges_for_TA))
a<-a[-1,]
colnames(a)<-t(Charges_for_TA[,1])
a<- data.frame(lapply(a, function(x) as.numeric(as.character(x))))


## Calcul des charges 
drop_var<-names(a) %in%CDO
a<-a[!drop_var]


#Stockage des variables concernées : ce sont les variables en colonne
liste_col=colnames(param_temps)[4:length(colnames(param_temps))]



cle_temps<-param_temps[,1:2]

#Boucle pour construire la variable de clé temps en fonction des effectifs temps
for (i in 1:length(liste_col))
{
  # Nouvelle variable de clé
  var<-stri_replace_all_fixed( paste("weight_",liste_col[i]), " ", "")
  #Variable sur laquelle calculer la clé
  code<-stri_replace_all_fixed(liste_col[i]," ","")
  # Construction de la variable
  cle_temps[[paste(var)]]=ifelse(param_temps[[paste(code)]]!="o",0,
                              param_temps$temps_min/sum(param_temps[which(param_temps[[paste(code)]]=="o"),]$temps_min))
#}
  # Traitement des cas particuliers où un seul poids existe, on fait le rapport sur la somme des effectifs
  cle_temps[[paste(var)]]<-ifelse(param_temps[[paste(code)]]=="o" 
                                    & param_temps$Code_Activite==11 
                                    #& param_temps[[paste(var)]]==a[1,i]
                                ,(param_temps$temps_min/sum(param_temps$temps_min))
                                ,cle_temps[[paste(var)]])
 
}
```
### Les traitements spécifiques
Toutes les activités ne suivent pas la même logique mathématique énoncée ci-haut pour calculer leurs clés temps. Il existe des cas spécifiques ; ces derniers sont :

* La charge 32: `Directeur de Secteur (DS)` est répartie via une clé temps agent des personnes encadrées. Cette clé est directement intégrée dans la table de paramétrage des clés temps en dur.
* La charge 33: `Responsable Espace Comercial (REC)` est répartie via une clé temps agent des personnes encadrées. Cette clé est directement intégrée dans la table de paramétrage des clés temps en dur.
* La charge 30 `CIE - Loyers et Charges Immobilicres (hors Cplts de Loyers)`, pour cette charge le réseau donne un montant qui se déverse sur l'hébergement des facteurs ainsi on doit calculer les clés de sorte à intégrer cette partie et avoir une répartition à 100%. La valeur fournie par le réseau est stockée en dur dans la variable `charge_heberge_facteur` 
* La charge 41 `SSM - Formation` c'est le même pricipe que la charge 30 , sauf qu'on doit retirer de la charge les prestation de formation, ensuite allouer un montant à la formation LBC et répartir le reste de sorte à tenir 100% avec la charge total en dehors des prestations de formation.


```r
## traitement spécifique
cle_temps$weight_code_32<-param_temps$code_32
cle_temps$weight_code_33<-param_temps$code_33

# traitement des clé mixtes

# Pour le code 30 on sait 
cle_temps<-cle_temps%>%
  mutate(weight_code_30=ifelse(is.na(weight_code_30),weight_code_30,weight_code_30*(a$code_30-charge_heberge_facteur)/a$code_30))

#sum(cle_temps$weight_code_30,na.rm=T)
cle_temps<-cle_temps%>%
  mutate(weight_code_30=ifelse(Code_Activite==2,1-sum(cle_temps$weight_code_30,na.rm=T),weight_code_30))
#sum(cle_temps$weight_code_30,na.rm=T)

# Pour le code 41
# on supprime les charges à enlever
a<-a%>%
  mutate(code_41=code_41-prestation_formation)

cle_temps<-cle_temps%>%
  mutate(weight_code_41=ifelse(is.na(weight_code_41),weight_code_41,weight_code_41*(a$code_41-Formation_LCB)/a$code_41))
#sum(cle_temps$weight_code_41,na.rm=T)

cle_temps<-cle_temps%>%
  mutate(weight_code_41=ifelse(Code_Activite==7,1-sum(cle_temps$weight_code_41,na.rm=T),weight_code_41))

#sum(cle_temps$weight_code_41,na.rm=T)

# Conversion des variables en numerique
cle_temps<-cle_temps%>%mutate_each(funs(as.numeric), starts_with("weight_"))
```

### Calcul des charges réparties aux clés temps : Répartition primaire

Après avoir calculé les clés temps et traité les cas spécifiques, nous pouvons calculer les charges ventilés aux clés temps. Nous appliquons juste le même principe énoncé ci-haut en multipliant les charges par les clés obtenues. C'est une répartition sur les activités opérationnelles sans prendre en compte la répartition sur les activités non opérationnelles.



```r
###################################################################################################################
#Boucle pour construire la variable des charges intermédiaires avec les clés temps en fonction des effectifs temps#
###################################################################################################################
for (i in 1:length(liste_col))
{
  # Nouvelle variable de clé
  var<-stri_replace_all_fixed( paste("weight_",liste_col[i]), " ", "")
  #Variable sur laquelle calculer la clé
  code<-stri_replace_all_fixed(liste_col[i]," ","")
  # Construction de la variable
  param_temps[[paste(var)]]=a[1,i]*cle_temps[[paste(var)]]
}
```





Ci-dessous, la matrice des clés temps

```r
kable(cle_temps, "html",caption = "Matrice des clés temps") %>%
  kable_styling() %>%
  scroll_box(width = "1000px", height = "300px")
```

<div style="border: 1px solid #ddd; padding: 5px; overflow-y: scroll; height:300px; overflow-x: scroll; width:1000px; "><table class="table" style="margin-left: auto; margin-right: auto;">
<caption>Matrice des clés temps</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> Code_Activite </th>
   <th style="text-align:left;"> Activite </th>
   <th style="text-align:right;"> weight_code_26 </th>
   <th style="text-align:right;"> weight_code_27 </th>
   <th style="text-align:right;"> weight_code_28 </th>
   <th style="text-align:right;"> weight_code_29 </th>
   <th style="text-align:right;"> weight_code_30 </th>
   <th style="text-align:right;"> weight_code_31 </th>
   <th style="text-align:right;"> weight_code_32 </th>
   <th style="text-align:right;"> weight_code_33 </th>
   <th style="text-align:right;"> weight_code_34 </th>
   <th style="text-align:right;"> weight_code_35 </th>
   <th style="text-align:right;"> weight_code_36 </th>
   <th style="text-align:right;"> weight_code_37 </th>
   <th style="text-align:right;"> weight_code_38 </th>
   <th style="text-align:right;"> weight_code_39 </th>
   <th style="text-align:right;"> weight_code_40 </th>
   <th style="text-align:right;"> weight_code_41 </th>
   <th style="text-align:right;"> weight_code_42 </th>
   <th style="text-align:right;"> weight_code_43 </th>
   <th style="text-align:right;"> weight_code_44 </th>
   <th style="text-align:right;"> weight_code_45 </th>
   <th style="text-align:right;"> weight_code_46 </th>
   <th style="text-align:right;"> weight_code_47 </th>
   <th style="text-align:right;"> weight_code_48 </th>
   <th style="text-align:right;"> weight_code_49 </th>
   <th style="text-align:right;"> weight_code_50 </th>
   <th style="text-align:right;"> weight_code_51 </th>
   <th style="text-align:right;"> weight_code_52 </th>
   <th style="text-align:right;"> weight_code_53 </th>
   <th style="text-align:right;"> weight_code_54 </th>
   <th style="text-align:right;"> weight_code_55 </th>
   <th style="text-align:right;"> weight_code_56 </th>
   <th style="text-align:right;"> weight_code_57 </th>
   <th style="text-align:right;"> weight_code_58 </th>
   <th style="text-align:right;"> weight_code_59 </th>
   <th style="text-align:right;"> weight_code_60 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> Activités Production CCC en BP </td>
   <td style="text-align:right;"> 0.0266884 </td>
   <td style="text-align:right;"> 0.0246373 </td>
   <td style="text-align:right;"> 0.0331449 </td>
   <td style="text-align:right;"> 0.0326293 </td>
   <td style="text-align:right;"> 0.0316859 </td>
   <td style="text-align:right;"> 0.0382600 </td>
   <td style="text-align:right;"> 0.0526527 </td>
   <td style="text-align:right;"> 0.0509553 </td>
   <td style="text-align:right;"> 0.0390627 </td>
   <td style="text-align:right;"> 0.0390627 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0276374 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0333295 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0333295 </td>
   <td style="text-align:right;"> 0.0333295 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0333295 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0371967 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Hébergement des facteurs </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0373681 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> Activités Production CCC hors BP </td>
   <td style="text-align:right;"> 0.0014873 </td>
   <td style="text-align:right;"> 0.0013730 </td>
   <td style="text-align:right;"> 0.0018472 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0015402 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0018575 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0018575 </td>
   <td style="text-align:right;"> 0.0018575 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0018575 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0020730 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> Commerçants </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> DPOM Corse Courrier </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0768525 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0862108 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.1039663 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.1039663 </td>
   <td style="text-align:right;"> 0.1039663 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.1039663 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> Activités Colis </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> Activités LCB en BP </td>
   <td style="text-align:right;"> 0.1763427 </td>
   <td style="text-align:right;"> 0.1627903 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.2155969 </td>
   <td style="text-align:right;"> 0.2093634 </td>
   <td style="text-align:right;"> 0.2528012 </td>
   <td style="text-align:right;"> 0.5100000 </td>
   <td style="text-align:right;"> 0.0322369 </td>
   <td style="text-align:right;"> 0.2581055 </td>
   <td style="text-align:right;"> 0.2581055 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.3873482 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.2202231 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.2202231 </td>
   <td style="text-align:right;"> 0.2202231 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.2202231 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.2457755 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> Responsable Clientcles Particuliers (RC Part) </td>
   <td style="text-align:right;"> 0.0143352 </td>
   <td style="text-align:right;"> 0.0132335 </td>
   <td style="text-align:right;"> 0.0178032 </td>
   <td style="text-align:right;"> 0.0175262 </td>
   <td style="text-align:right;"> 0.0170195 </td>
   <td style="text-align:right;"> 0.0205506 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0179023 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0179023 </td>
   <td style="text-align:right;"> 0.0179023 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0179023 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0199795 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Commissionnement LCB </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> Activités LCB hors BP </td>
   <td style="text-align:right;"> 0.0184529 </td>
   <td style="text-align:right;"> 0.0170347 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0230446 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0230446 </td>
   <td style="text-align:right;"> 0.0230446 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0230446 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0257185 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> Hébergement LCB </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0054095 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0056087 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0056087 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> Activités Guichet </td>
   <td style="text-align:right;"> 0.4801884 </td>
   <td style="text-align:right;"> 0.4432847 </td>
   <td style="text-align:right;"> 0.5963559 </td>
   <td style="text-align:right;"> 0.5870793 </td>
   <td style="text-align:right;"> 0.5701051 </td>
   <td style="text-align:right;"> 0.6883882 </td>
   <td style="text-align:right;"> 0.4373473 </td>
   <td style="text-align:right;"> 0.9168078 </td>
   <td style="text-align:right;"> 0.7028318 </td>
   <td style="text-align:right;"> 0.7028318 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.4972633 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.5996767 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.5996767 </td>
   <td style="text-align:right;"> 0.5996767 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.5996767 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.6692568 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:left;"> Charges Cantonnées </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 30 </td>
   <td style="text-align:left;"> CIE - Loyers et Charges Immobilicres (hors Cplts de Loyers) </td>
   <td style="text-align:right;"> 0.0116780 </td>
   <td style="text-align:right;"> 0.0107805 </td>
   <td style="text-align:right;"> 0.0145032 </td>
   <td style="text-align:right;"> 0.0142776 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 32 </td>
   <td style="text-align:left;"> Directeur de Secteur (DS) </td>
   <td style="text-align:right;"> 0.0355822 </td>
   <td style="text-align:right;"> 0.0328476 </td>
   <td style="text-align:right;"> 0.0441903 </td>
   <td style="text-align:right;"> 0.0435029 </td>
   <td style="text-align:right;"> 0.0422451 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 33 </td>
   <td style="text-align:left;"> Responsable Espace Comercial (REC) </td>
   <td style="text-align:right;"> 0.0478178 </td>
   <td style="text-align:right;"> 0.0441429 </td>
   <td style="text-align:right;"> 0.0593860 </td>
   <td style="text-align:right;"> 0.0584622 </td>
   <td style="text-align:right;"> 0.0567719 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 34 </td>
   <td style="text-align:left;"> Responsable d'Exploitation (REX) </td>
   <td style="text-align:right;"> 0.0252950 </td>
   <td style="text-align:right;"> 0.0233510 </td>
   <td style="text-align:right;"> 0.0314143 </td>
   <td style="text-align:right;"> 0.0309257 </td>
   <td style="text-align:right;"> 0.0300315 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 35 </td>
   <td style="text-align:left;"> CIE - Autres </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 37 </td>
   <td style="text-align:left;"> ST - Locaux </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 38 </td>
   <td style="text-align:left;"> ST - Autres </td>
   <td style="text-align:right;"> 0.1359348 </td>
   <td style="text-align:right;"> 0.1254879 </td>
   <td style="text-align:right;"> 0.1688203 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 39 </td>
   <td style="text-align:left;"> Structures Nationales </td>
   <td style="text-align:right;"> 0.0077679 </td>
   <td style="text-align:right;"> 0.0071709 </td>
   <td style="text-align:right;"> 0.0096471 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 40 </td>
   <td style="text-align:left;"> Charges diverses </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:left;"> SSM - Formation </td>
   <td style="text-align:right;"> 0.0079256 </td>
   <td style="text-align:right;"> 0.0073165 </td>
   <td style="text-align:right;"> 0.0098429 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 45 </td>
   <td style="text-align:left;"> SSM - Comptabilité Bureau </td>
   <td style="text-align:right;"> 0.0105037 </td>
   <td style="text-align:right;"> 0.0096965 </td>
   <td style="text-align:right;"> 0.0130448 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 48 </td>
   <td style="text-align:left;"> SSM - Social </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 49 </td>
   <td style="text-align:left;"> SSM - Syndical </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 50 </td>
   <td style="text-align:left;"> SSM - DSEM </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
</tbody>
</table></div>

Ci-dessous la matrice des charges obtenus par ventilation avec les clés temps



Le programme ci-dessus nous a permis de calculer les clés temps, mais aussi les charges intermédiaires liées à ces clés temps. 

Dans la partie qui suit, nous allons calculer les clés au taux de frais qui dépendent des charges intermédiaires qui ont été calculées à partir des temps.

## Calcul des clés taux de frais

### Méthodologie 
Les clefs basées sur les coûts (taux de frais) doivent être calculées à partir des coûts directs des activités opérationnelles (codes 1 à 25) + charges indirectes réparties (codes 26 à 35).
Les coûts directs des activités opérationnelles ont été identifiés via le mécanisme de marquage. Nous allons coupler cette information avec les coûts indirectes issues de la ventilation via les clés temps pour déterminer les clés au taux de frais.


<center>
![](param_tf.PNG)
</center>



Ces clés au taux de frais s'appliquent à des activités opérationnelles. Pour définir les opérations sur lesquelles ils s'appliquent, nous utilisons un autre fichier de paramétrage similaire au paramétrage des clés temps./n
Voici les étapes de calcul des clés au taux de frais sur les différentes activités qui doivent en bénéficier.

1. On calcule les coûts directes des opérations ayant les codes 1 à 25
2. On calcule les coûts indirectes issues de la répartition via les clés temps pour les codes 11 à 20
3. On somme les coûts directs avec les coûts indirects des opérations de code 1 à 25 pour les charges sur les opérations de 26 à 35.
4. On importe le paramétrage des taux de frais.
5. On calcule le poids.


Soit $\mathbb{1}_{j}(o)$ l'indicatrice qui indique si une charge doit être déversée ou non sur les activités opérationnelles. On note $CDI^{j}$ les charges directes et indirectes de l'activité opérationnelle $j$.<br/> On note $Wtf_{k}^{j}$ la clé au taux de frais de l'activité k sur l'activité j. $Wtf_{k}^ {j}$ est définis par : 

$$ Wtf_{k}^{j}=\frac{CDI^{j}}{\sum_{i}(\mathbb{1}_{i}(o))*CDI^{i}} $$

<center>
![](TF.jpg){width=50%}
</center>


```r
## Création de la table des coûts directes des activités opérationnelles
cout_dir_op<-Charges_for_TA[which(Charges_for_TA$code %in% CDO),] #c('code_1','code_2','code_3','code_4','code_5','code_6','code_7','code_8','code_9','code_10')),]

# calcul des coûts indirectes
couts_indir<-param_temps%>%filter(Code_Activite%in% c(1:25))%>%
                            select(.dots = CIO_int)
names(couts_indir)<-CIO_int

# Calcul des coûts indirecte
couts_indir$code<-stri_replace_all_fixed( paste("code_",couts_indir$Code_Activite), " ", "")

# jointure des coûts directes avec les coûts indirectes
couts_dir_indir<-full_join(cout_dir_op,couts_indir)
couts_dir_indir<- arrange(couts_dir_indir, code)
drop.cols<-"Code_Activite"
couts_dir_indir<-couts_dir_indir%>%select(-one_of(drop.cols))

# Remplacement par zéros des coûts manquants
couts_dir_indir[is.na(couts_dir_indir)] <- 0
couts_dir_indir<-couts_dir_indir%>%
  mutate(charges=rowSums(couts_dir_indir[,2:12]))%>%
  select(code,charges)

  
## Utilisation du paramétrage des clés taux de frais
param_tf<-param_tf%>%
  mutate(code=stri_replace_all_fixed( paste("code_",Code_Activite), " ", ""))%>%
  filter(code %in% couts_indir$code)%>%
  arrange(code)

couts_dir_indir<-left_join(couts_dir_indir,param_tf)

rm("couts_indir", "cout_dir_op")
```
 
Après avoir arrangé les tables on peut procéder au calcul des clés au taux de frais.


```r
liste_col=colnames(couts_dir_indir)[5:(length(colnames(couts_dir_indir)))]

cle_tf<-couts_dir_indir[,c(1,3,4)]
#Boucle pour construire la variable de clé temps en fonction des effectifs temps
for (i in 1:length(liste_col))
{
  # Nouvelle variable de clé
  var<-stri_replace_all_fixed( paste("weight_",liste_col[i]), " ", "")
  #Variable sur laquelle calculer la clé
  code<-stri_replace_all_fixed(liste_col[i]," ","")
  # Construction de la variable
  cle_tf[[paste(var)]]=ifelse(couts_dir_indir[[paste(code)]]!="o",0,
                              couts_dir_indir$charges/sum(couts_dir_indir[which(couts_dir_indir[[paste(code)]]=="o"),]$charges))
  
}
```


```r
#kable(couts_dir_indir[,-c(5:40)], format = "markdown")
kable(cle_tf, "html") %>%
  kable_styling() %>%
  scroll_box(width = "900px", height = "500px")
```

<div style="border: 1px solid #ddd; padding: 5px; overflow-y: scroll; height:500px; overflow-x: scroll; width:900px; "><table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> code </th>
   <th style="text-align:right;"> Code_Activite </th>
   <th style="text-align:left;"> Activite </th>
   <th style="text-align:left;"> weight_code_26 </th>
   <th style="text-align:left;"> weight_code_27 </th>
   <th style="text-align:left;"> weight_code_28 </th>
   <th style="text-align:left;"> weight_code_29 </th>
   <th style="text-align:left;"> weight_code_30 </th>
   <th style="text-align:left;"> weight_code_31 </th>
   <th style="text-align:left;"> weight_code_32 </th>
   <th style="text-align:left;"> weight_code_33 </th>
   <th style="text-align:left;"> weight_code_34 </th>
   <th style="text-align:left;"> weight_code_35 </th>
   <th style="text-align:right;"> weight_code_36 </th>
   <th style="text-align:right;"> weight_code_37 </th>
   <th style="text-align:right;"> weight_code_38 </th>
   <th style="text-align:right;"> weight_code_39 </th>
   <th style="text-align:right;"> weight_code_40 </th>
   <th style="text-align:left;"> weight_code_41 </th>
   <th style="text-align:right;"> weight_code_42 </th>
   <th style="text-align:left;"> weight_code_43 </th>
   <th style="text-align:left;"> weight_code_44 </th>
   <th style="text-align:right;"> weight_code_45 </th>
   <th style="text-align:right;"> weight_code_46 </th>
   <th style="text-align:right;"> weight_code_47 </th>
   <th style="text-align:left;"> weight_code_48 </th>
   <th style="text-align:left;"> weight_code_49 </th>
   <th style="text-align:right;"> weight_code_50 </th>
   <th style="text-align:left;"> weight_code_51 </th>
   <th style="text-align:right;"> weight_code_52 </th>
   <th style="text-align:right;"> weight_code_53 </th>
   <th style="text-align:right;"> weight_code_54 </th>
   <th style="text-align:right;"> weight_code_55 </th>
   <th style="text-align:left;"> weight_code_56 </th>
   <th style="text-align:right;"> weight_code_57 </th>
   <th style="text-align:left;"> weight_code_58 </th>
   <th style="text-align:left;"> weight_code_59 </th>
   <th style="text-align:left;"> weight_code_13 </th>
   <th style="text-align:left;"> weight_code_60 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> code_1 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> Activités Production CCC en BP </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0321489 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0354620 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_10 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> Activités LCB hors BP </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_11 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> Hébergement LCB </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_12 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> Activités Guichet </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.6184304 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.6821628 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_13 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_2 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> Hébergement des facteurs </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_3 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> Activités Production CCC hors BP </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_4 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_5 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> DPOM Corse Courrier </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0813341 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_6 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_7 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> Activités LCB en BP </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.2387396 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.2633430 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_8 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> Responsable Clientcles Particuliers (RC Part) </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0172540 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0190321 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> code_9 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Commissionnement LCB </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0120930 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
  </tr>
</tbody>
</table></div>

```r
#datatable(couts_dir_indir[,-c(5:40)], rownames = FALSE)
```

## Calcul des clés finales : Répartition secondaire

Dans les étapes précédentes, nous avons calculé les clés au taux de frais et les clés au temps. Rappelons que l'objectif de la cascade est de déverser sur les activités opérationnelles toutes les charges des autres activités.


### Méthodologie

Nous avons vu avec les clés temps que certaines activités se déversent sur d'autres activités non-opérationnelles. Ansi certaines `CIO` sont répartis sur d'autres `CIO` qui sont eux-mêmes répartis sur les `CDO`. Il convient donc de mettre à jour les clés sur les `CIO` des activités qui ont un bout qui est réparti sur les autres `CIO`.<br/>
Dans cette partie, nous allons nous atteler à cette tâche pour obtenir les clés finales sur les activités opérationnelles.


```r
# On va créer une matrice de clé qui combine les clés au tausx de frais et les clés temps
cle_fin<-cle_temps

act_tf<-param_type_cle%>%
        filter(type_cle%in%c("taux de frais","temps et taux de frais"))%>%
        mutate(var=stri_replace_all_fixed( paste("weight_",Code), " ", ""))%>%
        select(var)

list_col<-act_tf$var

drop_var<-names(cle_fin) %in%list_col
cle_fin<-cle_fin[!drop_var]

# Découpage pour ordonner par code 
mystrsplit <- function(x, pattern, part=2){
  return(strsplit(x, pattern)[[1]][part])
}
# Vectorize it so that it can handle vector arguments of x
mystrsplit <- Vectorize(mystrsplit, vectorize.args = "x")

cle_tf<- cle_tf%>%mutate(Code_Activite=as.numeric(mystrsplit(code, '\\_', 2)))%>%
                  arrange(Code_Activite)



dat1<-cle_tf[,list_col]
dat2 <- data.frame(matrix(nrow = nrow(cle_fin)-nrow(dat1), ncol = ncol(dat1)))

names(dat2) <- names(dat1)

dat<-bind_rows(dat1, dat2)

cle_fin<-cbind(cle_fin,dat)

# Ordonner les colonnes
cle_fin<-cle_fin[,order(colnames(cle_fin))]

# Nettoyage de la mémoire
rm("dat1", "dat2", "dat","act_tf")
```

On peut commencer le calcul à proprement dit des clés finales. Mais avant de commencer, on va traiter des cas spécifiques. Il s'agit des clés avec les codes 50 et 52. Ces derniers se répartissent en parti grâce aux clés temps sur l'activité 11 puis le reste est réparti au taux de frais.


```r
# on sait que pour les activités 50 et 52, une partie se répartie via le temps et le reste se réparti avec les clés taux de frais. Voici le traitement de cette règle:

cle_temps_heb=cle_temps[which(cle_temps$Code_Activite==11),]$weight_code_50
cle_fin<-cle_fin%>%
  mutate(weight_code_50=ifelse(is.na(weight_code_50),weight_code_50,weight_code_50*(1-cle_temps_heb)))

cle_fin[which(cle_fin$Code_Activite==11),]$weight_code_50=cle_temps_heb
#sum(cle_fin$weight_code_50,na.rm=T)

cle_fin<-cle_fin%>%
  mutate(weight_code_52=ifelse(is.na(weight_code_52),weight_code_52,weight_code_52*(1-cle_temps_heb)))

cle_fin[which(cle_fin$Code_Activite==11),]$weight_code_52=cle_temps_heb
#sum(cle_fin$weight_code_52,na.rm=T)
```

Une fois ces cas gérés, nous passons au traitement des charges qui se déversent sur d'autres charges non-opérationnelles. Nous en profitons pour créer en même temps la table des clés finales.<br/>
Avant de commencer ce traitement à proprement dit, essayons de formaliser concrétement ce que nous faisont dans cette partie.

* On note $W^{ij}_{CDO-CIO}$  la clé primaire de la CIO $j$ qui se déverse dans un CDO $i$.
* On note $W^{jk}_{CIO-CIO}$  la clé primaire de la CIO $j$ qui se déverse dans un CIO $k$.

La clé finale de l'activité j sur l'activité opérationnelle i est données par :

$$ W^{ij}_{fin}=W^{ij}_{CDO-CIO} + \sum_{k}W^{jk}_{CIO-CIO}*W^{ik}_{CDO-CIO}  $$

Ce formalise suppose un ordre de traitement des clés pour tenir compte des cas d'imbrication.
Dans le cas de la cascade en date de février 2018, seul l'activité 30 présente une imbrication de clés ainsi, il convient de traiter cette activité en premier et de mettre à jour les clés primaires avant le calcul de la clé finale des autres CIO.



```r
# Selection des codes activité 1 à 25: les COD 
# C'est la table de la répartition sur les activités opérationnelles
# Ces clés ne font pas 100% car il y a une partie qui va se déverser sur les activités non opérationnelles
cle_ini<-cle_fin%>%
  filter(Code_Activite%in%c(1:25))%>%
  arrange(Code_Activite)

# On remplace les valeurs manquantes par zeros
cle_ini[is.na(cle_ini)]<-0

# On selectionne clés sur les COD des activités COI qui se déversent dans d'autres COI. Voir si on ne peut pas les mettre en paramètre.
# C'est la répartion sur les activités opérationnelles des activités non opérationnelles sur lesquelles se déversent d'autres activités non opérationnelles
cle_int<-cle_ini%>%
  select(c("weight_code_30",
            "weight_code_32",
            "weight_code_33",
            "weight_code_34",
            "weight_code_35",
            "weight_code_38",
            "weight_code_39",
            "weight_code_40",
            "weight_code_41",
            "weight_code_45"))
  
# transoposition de la matrice pour faciliter les opérations de calcul
cle_int<-as.data.frame(t(cle_int))

# Clé des COI qui se déversent sur les autres COI
cle_venti<-cle_temps%>%
  filter(Code_Activite%in%c(30,
                          32,
                          33,
                          34,
                          35,
                          38,
                          39,
                          40,
                          41,
                          45))%>%
  arrange(Code_Activite)%>%
  select(3:7)
  
cle_venti[is.na(cle_venti)]<-0  

# Append des deux tables 
cle_venti<-cbind(cle_venti,cle_int)


## Cette fonction permet de calculer la clé correcte des COD pour les COI qui se déversent sur d'autre COI
correct_cle <- function(data, cle){
var<-data[[paste(cle)]]
test<-data%>%
          mutate_each(funs(.*var), starts_with("V"))
test<-test %>% summarize_each(funs(sum), starts_with("V"))  
test<-as.data.frame(t(test))


insertRow <- function(existingDF, newrow, r) {
  existingDF[seq(r+1,nrow(existingDF)+1),] <- existingDF[seq(r,nrow(existingDF)),]
  existingDF[r,] <- newrow
  existingDF
}

#newrow <- 0
#test <- insertRow(test,newrow,3)
test<-as.matrix(test)
#cle_venti$newvar<-test[,1]
return(test)
}

cle_cor<-cle_ini[,1:7]
#Modif
cle_cor$cor_weight_code_30=as.numeric(correct_cle(cle_venti,"weight_code_30")+cle_cor$weight_code_30)

cle_venti[1,6:length(cle_venti)]<-t(cle_cor$cor_weight_code_30)

liste_col=colnames(cle_venti)[1:4]
```


### Calcul des clés finales


```r
# Boucle pour le calcul des clés finales
for (i in 1:length(liste_col))
{
  # Nouvelle variable de clé
  var<-stri_replace_all_fixed( paste("cor_",liste_col[i]), " ", "")
  #Variable sur laquelle calculer la clé
  code<-stri_replace_all_fixed(liste_col[i]," ","")
  # Construction de la variable
  cle_cor[[paste(var)]]=as.numeric(correct_cle(cle_venti,code)+cle_cor[[paste(code)]])
}
#??? déplacement en dernier position
cle_cor<-cle_cor%>%select(-cor_weight_code_30,cor_weight_code_30)

col_names<-colnames(cle_cor[,3:7])
cle_cor<-cle_cor[,-c(3:7)]
names(cle_cor)[3:length(cle_cor)]<-col_names
cle_cor<-cbind(cle_cor,cle_ini[,8:ncol(cle_ini)])

rm("cle_ini", "cle_int", "cle_venti","a","cle_fin","Charges_for_TA","couts_dir_indir")
```



```r
#kable(couts_dir_indir[,-c(5:40)], format = "markdown")
kable(cle_cor, "html") %>%
  kable_styling() %>%
  scroll_box(width = "1000px", height = "400px")
```

<div style="border: 1px solid #ddd; padding: 5px; overflow-y: scroll; height:400px; overflow-x: scroll; width:1000px; "><table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Activite </th>
   <th style="text-align:right;"> Code_Activite </th>
   <th style="text-align:right;"> weight_code_26 </th>
   <th style="text-align:right;"> weight_code_27 </th>
   <th style="text-align:right;"> weight_code_28 </th>
   <th style="text-align:right;"> weight_code_29 </th>
   <th style="text-align:right;"> weight_code_30 </th>
   <th style="text-align:right;"> weight_code_31 </th>
   <th style="text-align:right;"> weight_code_32 </th>
   <th style="text-align:right;"> weight_code_33 </th>
   <th style="text-align:right;"> weight_code_34 </th>
   <th style="text-align:right;"> weight_code_35 </th>
   <th style="text-align:right;"> weight_code_36 </th>
   <th style="text-align:right;"> weight_code_37 </th>
   <th style="text-align:right;"> weight_code_38 </th>
   <th style="text-align:right;"> weight_code_39 </th>
   <th style="text-align:right;"> weight_code_40 </th>
   <th style="text-align:right;"> weight_code_41 </th>
   <th style="text-align:right;"> weight_code_42 </th>
   <th style="text-align:right;"> weight_code_43 </th>
   <th style="text-align:right;"> weight_code_44 </th>
   <th style="text-align:right;"> weight_code_45 </th>
   <th style="text-align:right;"> weight_code_46 </th>
   <th style="text-align:right;"> weight_code_47 </th>
   <th style="text-align:right;"> weight_code_48 </th>
   <th style="text-align:right;"> weight_code_49 </th>
   <th style="text-align:right;"> weight_code_50 </th>
   <th style="text-align:right;"> weight_code_51 </th>
   <th style="text-align:right;"> weight_code_52 </th>
   <th style="text-align:right;"> weight_code_53 </th>
   <th style="text-align:right;"> weight_code_54 </th>
   <th style="text-align:right;"> weight_code_55 </th>
   <th style="text-align:right;"> weight_code_56 </th>
   <th style="text-align:right;"> weight_code_57 </th>
   <th style="text-align:right;"> weight_code_58 </th>
   <th style="text-align:right;"> weight_code_59 </th>
   <th style="text-align:right;"> weight_code_60 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Activités Production CCC en BP </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.0379243 </td>
   <td style="text-align:right;"> 0.0350097 </td>
   <td style="text-align:right;"> 0.0470990 </td>
   <td style="text-align:right;"> 0.0396491 </td>
   <td style="text-align:right;"> 0.0379762 </td>
   <td style="text-align:right;"> 0.0382600 </td>
   <td style="text-align:right;"> 0.0526527 </td>
   <td style="text-align:right;"> 0.0509553 </td>
   <td style="text-align:right;"> 0.0390627 </td>
   <td style="text-align:right;"> 0.0390627 </td>
   <td style="text-align:right;"> 0.0321489 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0276374 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0333295 </td>
   <td style="text-align:right;"> 0.0354620 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:right;"> 0.0333295 </td>
   <td style="text-align:right;"> 0.0333295 </td>
   <td style="text-align:right;"> 0.0339257 </td>
   <td style="text-align:right;"> 0.0333295 </td>
   <td style="text-align:right;"> 0.0339257 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:right;"> 0.0341171 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:right;"> 0.0371967 </td>
   <td style="text-align:right;"> 0.0314063 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hébergement des facteurs </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 0.0004364 </td>
   <td style="text-align:right;"> 0.0004028 </td>
   <td style="text-align:right;"> 0.0005420 </td>
   <td style="text-align:right;"> 0.0005335 </td>
   <td style="text-align:right;"> 0.0373681 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Activités Production CCC hors BP </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0.0017757 </td>
   <td style="text-align:right;"> 0.0016392 </td>
   <td style="text-align:right;"> 0.0022052 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0015402 </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0018575 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:right;"> 0.0018575 </td>
   <td style="text-align:right;"> 0.0018575 </td>
   <td style="text-align:right;"> 0.0019107 </td>
   <td style="text-align:right;"> 0.0018575 </td>
   <td style="text-align:right;"> 0.0019107 </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:right;"> 0.0019214 </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:right;"> 0.0020730 </td>
   <td style="text-align:right;"> 0.0017688 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Commerçants </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DPOM Corse Courrier </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 0.0006833 </td>
   <td style="text-align:right;"> 0.0774833 </td>
   <td style="text-align:right;"> 0.0008486 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0813341 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0862108 </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.1039663 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:right;"> 0.1039663 </td>
   <td style="text-align:right;"> 0.1039663 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.1039663 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0794553 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Activités Colis </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Activités LCB en BP </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 0.2476122 </td>
   <td style="text-align:right;"> 0.2285826 </td>
   <td style="text-align:right;"> 0.0885111 </td>
   <td style="text-align:right;"> 0.2510837 </td>
   <td style="text-align:right;"> 0.2404898 </td>
   <td style="text-align:right;"> 0.2528012 </td>
   <td style="text-align:right;"> 0.5100000 </td>
   <td style="text-align:right;"> 0.0322369 </td>
   <td style="text-align:right;"> 0.2581055 </td>
   <td style="text-align:right;"> 0.2581055 </td>
   <td style="text-align:right;"> 0.2387396 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.3873482 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.2202231 </td>
   <td style="text-align:right;"> 0.2633430 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:right;"> 0.2202231 </td>
   <td style="text-align:right;"> 0.2202231 </td>
   <td style="text-align:right;"> 0.2519342 </td>
   <td style="text-align:right;"> 0.2202231 </td>
   <td style="text-align:right;"> 0.2519342 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:right;"> 0.2533552 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:right;"> 0.2457755 </td>
   <td style="text-align:right;"> 0.2332248 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Responsable Clientcles Particuliers (RC Part) </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 0.0173651 </td>
   <td style="text-align:right;"> 0.0160305 </td>
   <td style="text-align:right;"> 0.0215661 </td>
   <td style="text-align:right;"> 0.0177692 </td>
   <td style="text-align:right;"> 0.0170195 </td>
   <td style="text-align:right;"> 0.0205506 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0172540 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0179023 </td>
   <td style="text-align:right;"> 0.0190321 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:right;"> 0.0179023 </td>
   <td style="text-align:right;"> 0.0179023 </td>
   <td style="text-align:right;"> 0.0182076 </td>
   <td style="text-align:right;"> 0.0179023 </td>
   <td style="text-align:right;"> 0.0182076 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:right;"> 0.0183103 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:right;"> 0.0199795 </td>
   <td style="text-align:right;"> 0.0168555 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Commissionnement LCB </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 0.0018442 </td>
   <td style="text-align:right;"> 0.0017024 </td>
   <td style="text-align:right;"> 0.0022903 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0120930 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0127613 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0127613 </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:right;"> 0.0128333 </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0118136 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Activités LCB hors BP </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 0.0217828 </td>
   <td style="text-align:right;"> 0.0201087 </td>
   <td style="text-align:right;"> 0.0041355 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0230446 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:right;"> 0.0230446 </td>
   <td style="text-align:right;"> 0.0230446 </td>
   <td style="text-align:right;"> 0.0230421 </td>
   <td style="text-align:right;"> 0.0230446 </td>
   <td style="text-align:right;"> 0.0230421 </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:right;"> 0.0231721 </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:right;"> 0.0257185 </td>
   <td style="text-align:right;"> 0.0213309 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hébergement LCB </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 0.0000632 </td>
   <td style="text-align:right;"> 0.0000583 </td>
   <td style="text-align:right;"> 0.0000785 </td>
   <td style="text-align:right;"> 0.0000772 </td>
   <td style="text-align:right;"> 0.0054095 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0056087 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0056087 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Activités Guichet </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 0.6705129 </td>
   <td style="text-align:right;"> 0.6189823 </td>
   <td style="text-align:right;"> 0.8327239 </td>
   <td style="text-align:right;"> 0.6908872 </td>
   <td style="text-align:right;"> 0.6617369 </td>
   <td style="text-align:right;"> 0.6883882 </td>
   <td style="text-align:right;"> 0.4373473 </td>
   <td style="text-align:right;"> 0.9168078 </td>
   <td style="text-align:right;"> 0.7028318 </td>
   <td style="text-align:right;"> 0.7028318 </td>
   <td style="text-align:right;"> 0.6184304 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.4972633 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0.5996767 </td>
   <td style="text-align:right;"> 0.6821628 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:right;"> 0.5996767 </td>
   <td style="text-align:right;"> 0.5996767 </td>
   <td style="text-align:right;"> 0.6526096 </td>
   <td style="text-align:right;"> 0.5996767 </td>
   <td style="text-align:right;"> 0.6526096 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:right;"> 0.6562906 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:right;"> 0.6692568 </td>
   <td style="text-align:right;"> 0.6041448 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Charges Cantonnées </td>
   <td style="text-align:right;"> 13 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table></div>


### Vérification des clés

```r
#kable(couts_dir_indir[,-c(5:40)], format = "markdown")
kable(as.data.frame(colSums(cle_cor[,-c(1:2)]),col.names="Somme_cle"), "html") %>%
  kable_styling() %>%
  scroll_box(width = "500px", height = "400px")
```

<div style="border: 1px solid #ddd; padding: 5px; overflow-y: scroll; height:400px; overflow-x: scroll; width:500px; "><table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> colSums(cle_cor[, -c(1:2)]) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> weight_code_26 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_27 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_28 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_29 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_30 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_31 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_32 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_33 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_34 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_35 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_36 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_37 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_38 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_39 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_40 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_41 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_42 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_43 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_44 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_45 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_46 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_47 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_48 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_49 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_50 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_51 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_52 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_53 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_54 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_55 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_56 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_57 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_58 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_59 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weight_code_60 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table></div>

```r
#View(as.data.frame(colSums(cle_cor[,-c(1:2)])))

#p <- ggplot(data=cle_cor, aes(x=Activite, y=weight_code_26)) +
#    geom_bar(stat="identity")
#ggplotly(p)
```


### Application des clés à la base des charges
Dans les étapes précédentes, nous avons calculer les pondérations de ventilation de toutes les activités sur les charges opérationnelles. </br>
Ces pondérations doivent être appliquée aux activités non opérationnelles pour avoir la cascade des coûts.


```r
code<-stri_replace_all_fixed( paste("code_",cle_cor$Code_Activite), " ", "")
cle_cor<-cbind(code,cle_cor)

# Transposition de la table des clés
cols <- as.character(cle_cor$code)
test<-cle_cor[,-c(1,2,3)]
#rownames(test)<-cols

t_cle_cor<-as.data.frame(t(test))

code<-row.names(t_cle_cor)
t_cle_cor$code<-substr(code, 8, 15)

## Fusion avec la base de charge

data_cascade<-left_join(data,t_cle_cor)
```

```
## Joining, by = "code"
```

```r
data_cascade<-data_cascade%>% mutate_each(funs(.*Ch_AP_Ret), starts_with("code_"))
```

```
## `mutate_each()` is deprecated.
## Use `mutate_all()`, `mutate_at()` or `mutate_if()` instead.
## To map `funs` over a selection of variables, use `mutate_at()`
```

