<p align="center">
  <img src="assets/images/salawa_logo_black.png#gh-light-mode-only" width="200" alt="Salawa" />
  <img src="assets/images/salawa_logo_white.png#gh-dark-mode-only" width="200" alt="Salawa" />
</p>

# Salawa — DMD Lab

Application minimaliste pour connaître les heures de prières de Paris et écouter Radio Orient — conçue pour être utilisable par tous, y compris les personnes âgées ou ne sachant pas lire, grâce à des indicateurs visuels clairs et une interface volontairement simple. Sans pub, sans compte.

[Voir la roadmap →](ROADMAP.md)

## Pourquoi cette app

Salawa est née d'un besoin concret : permettre aux personnes âgées ou ayant des difficultés avec la lecture de savoir en un coup d'œil si une prière est passée, en cours ou à venir — sans chercher dans un tableau, sans lire des colonnes de chiffres.

L'interface met en avant la prochaine prière, indique visuellement celle en cours, et permet d'écouter Radio Orient en un tap.

## Stack

Flutter · Riverpod · GoRouter · just_audio · google_generative_ai · shared_preferences

## Couleurs

Fond vert `#13411B` · Accent or `#D4AF37`

## Fonctionnalités

- Horaires de prière du jour (source : grandemosqueedeparis.fr)
- Mise en évidence de la prochaine prière en temps réel (rafraîchissement à la minute)
- Indicateur clignotant sur la prière en cours
- Tap sur une prière → horloge analogique centrée
- Calendrier mensuel complet
- Récupération automatique chaque mois via scraping + analyse Gemini Vision
- Cache local mensuel (mois précédent supprimé automatiquement)
- Radio Orient en streaming (lecture en arrière-plan, contrôles écran de verrouillage)

## Variables d'environnement

Créer un fichier `secrets.json` à la racine du projet :

```json
{
  "GEMINI_API_KEY": "..."
}
```

## Lancer le projet

```bash
flutter pub get
flutter run --dart-define-from-file=secrets.json
```

## Build APK

```bash
flutter build apk --release --dart-define-from-file=secrets.json
```

---

<p align="center">
  <sub>Une app créée par</sub><br/>
  <img src="assets/images/dmdlab_logo_black.png#gh-light-mode-only" width="150" alt="DMD Lab" />
  <img src="assets/images/dmdlab_logo_white.png#gh-dark-mode-only" width="150" alt="DMD Lab" />
</p>
