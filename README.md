# Killer Management

Ce dépôt contient une interface web simple (`index.html`) et un script PowerShell (`script_killer.ps1`) conçus pour gérer à distance un hypothétique "tueur d'applications" s'exécutant sur des machines clientes.

**Veuillez noter :** Les noms "Killer Management" et "script_killer.ps1" sont utilisés à des fins illustratives sur la base du code fourni. Soyez extrêmement prudent lorsque vous nommez et utilisez des scripts qui terminent des processus, car ils peuvent avoir des conséquences imprévues et potentiellement nuisibles en cas de mauvaise utilisation.

## Interface Web (`index.html`)

Le fichier `index.html` est une page web côté client qui interagit avec une API distante. Pour l'utiliser :

1.  **Ouvrez `index.html` dans n'importe quel navigateur web.**
2.  **Notez l'URL de l'API :** Le script est configuré pour communiquer avec `https://68138d49129f6313e211a66e.mockapi.io/management/1`. Il s'agit d'une API factice et elle n'effectuera aucune gestion "killer" réelle.

    Voici un exemple de l'api :
    ```json
    [
        {
            "isActive": false,
            "message": {
                "message": "test de message",
                "incr": 16
            },
            "nbPcInfect": {
                "nbPcInfect": 1,
                "nbPcInfectIncr": 5
            },
            "nbLockSession": 0,
            "id": "1",
            "appsToBlocked": [
                "msedge",
                "chrome",
                "code"
            ],
            "blockUserInput": false
        }
    ]
    ```

## Considérations Importantes

* **Implications Éthiques :** L'utilisation de scripts pour forcer la fermeture d'applications sans le consentement de l'utilisateur a des implications éthiques importantes et peut être considérée comme malveillante. Ce code ne doit être utilisé que dans des environnements où vous avez une permission explicite et une raison légitime de le faire (par exemple, des environnements de test contrôlés).
* **Perte de Données Potentielle :** La fermeture forcée d'applications peut entraîner une perte de données si les utilisateurs ont un travail non sauvegardé.
* **Instabilité du Système :** La terminaison répétée d'applications peut potentiellement entraîner une instabilité du système.
* **Risques de Sécurité :** Le mécanisme d'auto-suppression pourrait être perçu comme un moyen d'échapper à la détection et pourrait être utilisé à mauvais escient.
* **API Factice :** Le code fourni utilise une API factice. Pour implémenter une fonctionnalité de gestion réelle, vous devrez remplacer cela par votre propre API sécurisée et fiable.
* **Gestion des Erreurs :** Bien que les scripts incluent une certaine gestion des erreurs, des mécanismes de journalisation et de gestion des erreurs plus robustes seraient nécessaires pour une utilisation en production.

## Clause de non-responsabilité

Ce code est fourni à des fins d'information et d'éducation uniquement. Les auteurs ne sont pas responsables de toute mauvaise utilisation ou de tout dommage causé par ce code. Utilisez-le de manière responsable et éthique.
