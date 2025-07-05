# Scrabble Solitaire en Shell

Un mini-jeu de Scrabble en ligne de commande (Bash), jouable en solo avec système de tirage, validation de mots, score et gestion du sac de lettres.

---

## Contenu du projet

- `Scrabble.sh` : script principal du jeu
- `Dictionnaire.txt` : liste de mots valides (un par ligne)
- `lettres.txt` : lettres du jeu, avec valeur et fréquence, format `Lettre,Points,Fréquence`
- `meilleur.txt` : score maximal enregistré

---

## Lancer le jeu

```bash
chmod +x Scrabble.sh
./Scrabble.sh
```

Note: Le script fonctionne uniquement dans un terminal compatible ANSI (Linux, macOS, ou WSL sur Windows).

---

## Règles du jeu

Le jeu se joue sur 10 tours.
À chaque tour, 7 lettres sont tirées aléatoirement depuis le sac.

Vous pouvez :
taper un mot avec les lettres proposées
appuyer sur Entrée pour passer le tour et tirer de nouvelles lettres
Le mot est accepté s’il :
 - est dans le dictionnaire (Dictionnaire.txt)
 - peut être formé avec les lettres du tirage

Le score est calculé selon les valeurs des lettres (cf. Lettres.txt)
Le score de chaque mot est affiché à chaque fin de tour

À la fin :
 - un récapitulatif est affiché
 - un fichier highscore.txt est mis à jour si le record est battu ou s'il n'y avait aucun score existant
 - possibilité de relancer une partie

---

## Structure des fichiers

`lettres.txt` (extrait)

```
A,1,9
B,3,2
C,3,2
D,2,4
E,1,15
```

`Dictionnaire.txt` (extrait)

```
arbre
chat
route
mot
```
