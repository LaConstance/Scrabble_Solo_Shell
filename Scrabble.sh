#!/bin/bash

#Couleurs pour l'affichage dans le shell
ROUGE="\033[1;31m" #Reponse invalide
VERT="\033[1;32m" #Reponse valide
VIOLET="\033[1;35m" #Tour pasee
BLEU="\033[1;34m" #Score
JAUNE="\033[1;33m" #Porte lettre
GRAS="\033[1m"
RESET="\033[0m" #Retour a la couleur de base du shell


clear
sleep 1 
echo -e "Bienvenue sur..."
sleep 3
clear
cat << "EOF" 


                              ________                       ______  ______  ______           
                            /__  ___/_____________________ ____  /_ ___  /_ ___  /_____      
                              _____ \ _  ___/__  ___/_  __ `/__  __ \__  __ \__  / _  _ \     
                              ____/ / / /__  _  /    / /_/ / _  /_/ /_  /_/ /_  /  /  __/     
                  __________/ _____/  \___/ _____    \__,_/  /_.___/ /_.___/ /_/   \___/      
   ______________ ___  /___(_)__  /_______ ____(_)_____________                               
   __  ___/_  __ \__  / __  / _  __/_  __ `/__  / __  ___/_  _ \                              
   _(__  ) / /_/ /_  /  _  /  / /_  / /_/ / _  /  _  /    /  __/                              
   /____/  \____/ /_/   /_/   \__/  \__,_/  /_/   /_/     \___/                               
                                                                                             
EOF
sleep 5

#verifie si les fichiers sont presents
for fichier in lettres.txt Dictionnaire.txt; 
do
    if [[ ! -f "$fichier" ]]; 
    then
        clear
        echo "Erreur : fichier manquant : $fichier"
        sleep 3
        exit 1
    fi
done

if [[ ! -f "meilleur.txt" ]]; 
then
    touch meilleur.txt
fi

clear
sed -i 's/\r//g' lettres.txt #supprime les retours chariots de windows
sed -i 's/\r//g' Dictionnaire.txt 
sed -i 's/\r//g' meilleur.txt 

#Initialisation de certaines variables globales
declare -A val_lettres
declare -a porte_lettres
declare -a historique
sac=()
mot=""
mot_min=""
mot_maj=""
total=0
max_score=0

if [[ -f meilleur.txt ]]; 
then
    max_score=$(<meilleur.txt)
    [[ "$max_score" =~ ^[0-9]+$ ]] || max_score=0 #verifie si c'est un nombre qui est dans le fichier sinon le meilleur score est mis a 0
fi

jouer="o"

reinitialiser_variables() {
    val_lettres=()
    porte_lettres=()
    historique=()
    sac=()
    mot=""
    mot_min=""
    mot_maj=""
    total=0
}

recuperer_lettres () {
    #fonction pour recuperer les infos sur lettres d'un fichier lettres.txt 
    while IFS=',' read -r l val freq; 
    do
        if [[ "$val" =~ ^[0-9]+$ && "$freq" =~ ^[0-9]+$ ]]; 
        then
            val_lettres[$l]=$val
            for ((i=0; i<freq; i++));
            do
                sac+=("$l")
            done
        fi
    done < "lettres.txt"

}

tirer_lettres () { 
    #fonction pour tirer des lettres et les mettre dans le porte lettres
    porte_lettres=()
    for ((i=0; i<7; i++)); 
    do
        if (( ${#sac[@]} == 0 )); then
            break
        fi
        local index=$((RANDOM % ${#sac[@]})) #prend l'index d'une lettre du sac
        l=${sac[index]}
        porte_lettres+=("$l") # ajoute la lettre au porte lettres
        unset sac[$index] #retire la lettre du sac
        sac=("${sac[@]}") #reindex le sac
    done
}

calculer_score() {
    #fonction pour calcculer le score pour obtenu pour un mot donne
    local mot="$1"
    local score=0
    for ((i=0; i<${#mot}; i++));
    do
        l="${mot:$i:1}"
        val=${val_lettres[$l]:-0}
        ((score += val))
    done
    echo "$score"
}

verif_mot() {
    #fonction pour verifier la validite d un mot dans le dictionnaire
    local mot=$1
    if grep -iq "^$mot$" Dictionnaire.txt; 
    then
        return 0 #mot valide
    else
        return 1 #mot invalide
    fi

}

verif_lettres() {
    #fonction pour verifier si les lettres du porte lettre sont presentes dans le mot entre par l'utilisateur
    local mot="$1"
    local -a l_dispo=("${porte_lettres[@]}")
    for ((i=0; i<${#mot}; i++ ));
    do
        local l="${mot:$i:1}"
        local valide=false
        for j in "${!l_dispo[@]}";
        do
            if [[ "${l_dispo[j]}" == "$l" ]];
            then
                unset l_dispo[j]
                valide=true
                break
            fi
        done
        if ! $valide;
        then
            return 1 #le mot ne pas etre forme a partir des lettres dispo
        fi
    done
    return 0 #le mot est faisable avec les lettres dispo 

}

completer_lettres() {
    while (( ${#porte_lettres[@]} < 7 && ${#sac[@]} > 0 )); 
    do
        local index=$((RANDOM % ${#sac[@]}))
        l=${sac[$index]}
        porte_lettres+=("$l")
        unset sac[$index] #retire la lettre du sac
        sac=("${sac[@]}") #reindex le sac
        porte_lettres=("${porte_lettres[@]}") #reindexage du porte lettres
    done
}

retirer_lettres_du_mot() {
    local mot="$1"
    for (( i=0; i<${#mot}; i++ )); 
    do
        local l="${mot:$i:1}"
        for j in "${!porte_lettres[@]}"; 
        do
            if [[ "${porte_lettres[$j]}" == "$l" ]]; 
            then
                unset porte_lettres[$j]
                break #permet de supprimer qu'une occurence
            fi
        done
    done
    porte_lettres=("${porte_lettres[@]}") #reindexage du tableau
}

pass_change_lettres() {
    #fonction pour changer toutes les lettres du porte lettres
    for l in "${porte_lettres[@]}"; 
    do
        sac+=("$l")  #remet chaque lettre dans le sac
    done

    tirer_lettres
}

affiche_porte_lettres() {
    #fonction qui permet d'afficher le porte lettres
    echo -e "${GRAS}Porte-lettres :${RESET}"
    for l in "${porte_lettres[@]}"; 
    do
        echo -e -n "[ ${JAUNE}$(echo "$l" | tr '[:lower:]' '[:upper:]')${RESET} ] " 
    done
    echo

}



while [[ "${jouer}" == "o" ]];
do
    reinitialiser_variables
    recuperer_lettres
    tirer_lettres
    for (( tour=1; tour<=10; tour++)); #boucle principale du jeu
    do 
        while true; 
        do
            clear
            echo -e "${GRAS}TOUR $tour ${RESET}"
            echo -ne "$(tput cup 0 $(( $(tput cols) - 25 )))${GRAS}Score : $total${RESET}" #affiche en haut a droite
            echo -ne "$(tput cup 1 $(( $(tput cols) - 25 )))${GRAS}Meilleur Score : $max_score${RESET}" 
            echo
            affiche_porte_lettres
            echo
            read -p "Entrer un mot (ou presser Entrer pour Passer le Tour) : " mot
            mot_min=$(echo "$mot" | tr '[:upper:]' '[:lower:]')
            mot_maj=$(echo "$mot" | tr '[:lower:]' '[:upper:]')
            
            if [[ -z "$mot" ]]; 
            then
                clear
                echo -e "${VIOLET}Tour passé${RESET}"
                pass_change_lettres
                sleep 3
                historique+=("Tour $tour : PASS")
                break
            fi

            if ! verif_mot "$mot_min";
            then
                clear
                echo -e "${ROUGE}Mot Invalide (hors dictionnaire) !${RESET}"
                sleep 3
                continue
            fi

            if ! verif_lettres "$mot_min";
            then
                clear
                echo -e "${ROUGE}Mot Invalide (lettres indisponibles) !${RESET}"
                sleep 3
                continue
            fi

            score=$(calculer_score "$mot_min")

            ((total += score))
            clear
            echo -e "${VERT}Mot accepte ! Score : $score${RESET}"
            retirer_lettres_du_mot "$mot_min"
            historique+=("Tour $tour : $mot_maj ($score pts)")
            completer_lettres
            sleep 3
            break
        done

    done

    if (( total > max_score ));
    then
        clear
        max_score=$total
        echo "$total" > meilleur.txt
        echo -e "${VERT}Nouveau record !${RESET} Meilleur Score = $total"
        sleep 3
    fi

    clear
    echo -e "${BLEU}============== FIN DE LA PARTIE ==============${RESET}"
    sleep 0.7
    for ligne in "${historique[@]}"; 
    do
        echo "- $ligne"
        sleep 0.5
    done
    echo
    echo -e "Score final : $total ${GRAS}|${RESET} ${VERT}Meilleur score : $max_score${RESET}"
    sleep 9

    while true;
    do
    clear
    read -p "Voulez-vous rejouer ? (o/n) : " jouer
    jouer=$(echo "$jouer" | tr '[:upper:]' '[:lower:]')
    if [[ "$jouer" == "o" || "$jouer" == "n" ]]; 
    then
        break
    else
        clear
        echo -e "${ROUGE}Entrée invalide /!\ ! ${RESET}"
        sleep 3
    fi
    done

done
clear