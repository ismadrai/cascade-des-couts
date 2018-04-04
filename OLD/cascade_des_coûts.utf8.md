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


preservec32613d5ae944cb0

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

