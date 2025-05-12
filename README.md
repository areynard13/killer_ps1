# Killer Management

Ce dépôt contient une interface web simple (`index.html`) et un script PowerShell (`script_killer.ps1`) conçus pour gérer à distance un hypothétique "tueur d'applications" s'exécutant sur des machines clientes.

**Veuillez noter :** Les noms "Killer Management" et "script_killer.ps1" sont utilisés à des fins illustratives sur la base du code fourni. Soyez extrêmement prudent lorsque vous nommez et utilisez des scripts qui terminent des processus, car ils peuvent avoir des conséquences imprévues et potentiellement nuisibles en cas de mauvaise utilisation.

## Aperçu

Le fichier `index.html` fournit une page web de base avec les fonctionnalités suivantes :

* **Afficher le nombre d'ordinateurs infectés :** Affiche un décompte récupéré d'une API distante.
* **Rafraîchir le nombre d'ordinateurs infectés :** Permet une mise à jour manuelle du nombre affiché.
* **Basculer l'activité du script :** Active ou désactive la fonctionnalité "killer" sur les clients gérés.
* **Afficher l'état d'activité actuel :** Indique si le script "killer" est actuellement actif ou inactif.
* **Envoyer un message :** Envoie un message texte destiné à être affiché sur les clients gérés.

Le fichier `script_killer.ps1` est un script PowerShell qui, lorsqu'il est exécuté sur une machine cliente, effectue les actions suivantes en fonction des données récupérées d'une API distante :

* **Vérifie périodiquement une API distante :** Récupère l'état actuel (`isActive`), un message et des compteurs pour les messages et les ordinateurs infectés.
* **Bascule la terminaison d'applications :** Si `isActive` est `true`, le script surveille et termine en continu les processus figurant sur une liste noire prédéfinie (`chrome`, `msedge`, `code`).
* **Affiche les messages :** Si un nouveau message est détecté depuis l'API, il affiche une boîte de message contextuelle à l'utilisateur.
* **Incrémente le nombre d'ordinateurs infectés :** Si la valeur `nbPcInfectIncr` de l'API change, le script incrémente un compteur local et met à jour la valeur `nbPcInfect` sur l'API.
* **Auto-suppression :** Le script implémente un mécanisme pour se copier dans le dossier temporaire et planifier la suppression du script original et de la copie temporaire après un court délai. Ceci est probablement destiné à rendre le script plus difficile à trouver et à supprimer.

## Configuration

### Interface Web (`index.html`)

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
            "id": "1"
        }
        ]
    ```

### Script Client (`script_killer.ps1`)

Le fichier `script_killer.ps1` doit être exécuté sur les machines clientes cibles.

1.  **Enregistrez `script_killer.ps1` à l'emplacement souhaité sur la machine cliente.**
**Soyez prudent lorsque vous modifiez la politique d'exécution, car cela peut avoir un impact sur la sécurité de votre système.**
3.  **Exécution du script :** Vous pouvez exécuter le script en ouvrant PowerShell, en naviguant vers le répertoire du script et en l'exécutant : `./script_killer.ps1`. Le script est conçu pour s'exécuter en arrière-plan sans fenêtre visible.

## Détails des Fonctionnalités

### Interface Web

* **Nombre d'ordinateurs infectés :** Le nombre affiché est récupéré du champ `nbPcInfect.nbPcInfect` de la réponse JSON de l'endpoint de l'API.
* **Bouton Rafraîchir :** Cliquer sur ce bouton déclenche une requête `PUT` vers l'endpoint de l'API, définissant `nbPcInfect.nbPcInfect` à `0` et incrémentant `nbPcInfect.nbPcInfectIncr`. Il récupère ensuite le nombre mis à jour.
* **Bouton Changer l'activité du script :** Cliquer sur ce bouton bascule la valeur `isActive` dans l'API et met à jour l'état affiché. Il y a un délai de refroidissement de 10 secondes après chaque clic.
* **Formulaire Envoyer un message :** Soumettre ce formulaire envoie une requête `PUT` à l'API, mettant à jour le `message.message` et incrémentant le compteur `message.incr`.

### Script PowerShell

* **Instance Initiale et Auto-Suppression :** Lors de la première exécution du script, il crée une copie temporaire de lui-même dans le répertoire `%TEMP%` et lance cette copie. Le script original et la copie temporaire sont ensuite planifiés pour être supprimés après 5 secondes.
* **Vérifications de la Base de Données :** La fonction `checkDataBase` récupère périodiquement des données de l'endpoint de l'API (`https://68138d49129f6313e211a66e.mockapi.io/management`).
* **Tueur d'Applications (`closeApp`) :** Cette fonction s'exécute dans un travail séparé et vérifie et termine en continu les processus nommés `chrome`, `msedge` ou `code`. Cette fonction n'est active que lorsque la valeur `isActive` de l'API est `true`.
* **Affichage de Messages (`showMessageBox`) :** Si la valeur `message.incr` de l'API est différente de la dernière valeur enregistrée, le script affiche le contenu de `message.message` dans une boîte de message contextuelle.
* **Nombre d'Ordinateurs Infectés :** Si la valeur `nbPcInfectIncr` de l'API change, le script incrémente un compteur local (qui n'est pas conservé localement entre les exécutions du script) et envoie une requête `PUT` pour mettre à jour la valeur `nbPcInfect` sur l'API.
* **Boucle Principale (`main`) :** La fonction `main` orchestre les vérifications de la base de données, le démarrage et l'arrêt du travail `closeApp`, et la logique d'affichage des messages.

## Considérations Importantes

* **Implications Éthiques :** L'utilisation de scripts pour forcer la fermeture d'applications sans le consentement de l'utilisateur a des implications éthiques importantes et peut être considérée comme malveillante. Ce code ne doit être utilisé que dans des environnements où vous avez une permission explicite et une raison légitime de le faire (par exemple, des environnements de test contrôlés).
* **Perte de Données Potentielle :** La fermeture forcée d'applications peut entraîner une perte de données si les utilisateurs ont un travail non sauvegardé.
* **Instabilité du Système :** La terminaison répétée d'applications peut potentiellement entraîner une instabilité du système.
* **Risques de Sécurité :** Le mécanisme d'auto-suppression pourrait être perçu comme un moyen d'échapper à la détection et pourrait être utilisé à mauvais escient.
* **API Factice :** Le code fourni utilise une API factice. Pour implémenter une fonctionnalité de gestion réelle, vous devrez remplacer cela par votre propre API sécurisée et fiable.
* **Gestion des Erreurs :** Bien que les scripts incluent une certaine gestion des erreurs, des mécanismes de journalisation et de gestion des erreurs plus robustes seraient nécessaires pour une utilisation en production.

## Clause de non-responsabilité

Ce code est fourni à des fins d'information et d'éducation uniquement. Les auteurs ne sont pas responsables de toute mauvaise utilisation ou de tout dommage causé par ce code. Utilisez-le de manière responsable et éthique.
