# Salawa — DMD Lab

Horaires de prière de la Grande Mosquée de Paris + radio difusant la chaîne Radio Orient. Sans pub, sans compte.

## Stack

Flutter · Riverpod · GoRouter · just_audio · google_generative_ai · shared_preferences

## Couleurs

Fond vert `#13411B` · Accent or `#D4AF37`

## Fonctionnalités

- Horaires de prière du jour (source : grandemosqueedeparis.fr)
- Mise en évidence de la prochaine prière
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
