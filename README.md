# Scrabble Solitaire en Shell

Un mini-jeu de Scrabble en ligne de commande (Bash), jouable en solo avec système de tirage, validation de mots, score et gestion du sac de lettres.

---

## Contenu du projet

- `Scrabble.sh` : script principal du jeu
- `Dictionnaire.txt` : liste de mots valides (un par ligne)
- `Lettres.txt` : lettres du jeu, avec valeur et fréquence, format `Lettre,Points,Fréquence`
- `highscore.txt` : score maximal enregistré

---

## Lancer le jeu

```bash
chmod +x Scrabble.sh
./Scrabble.sh
