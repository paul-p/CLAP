# CLAP
CLAviers Partagés - Un système complet de gestion d'un parc d'ordinateurs en libre-service

## Prérequis
Installez une version de xubuntu 18.04.05 sur plusieurs PCs.
L'un sera le poste "administrateur" qui vous permettra de personnaliser, controler, surveiller et mettre à jour les autres postes dits "invités". Utiliser le cryptage du disque dur au moins sur cette machine.
Configurez le même utilisateur et le même mot de passe sur tous les PCs invités.
Les postes invités sont des versions de xubuntu personalisées afin d'offrir un poste "libre accès".

## Initialisation du poste "administateur"

### Installation du serveur AWX
Une fois les PCs installés. Connectez vous à la machine "administrateur" et executez ceci en ligne de commande
```
sudo apt-get install -y git && rm -rf ~/CLAP && git clone -b main https://github.com/paul-p/CLAP.git ~/CLAP && ~/CLAP/bootstrap.sh
```
Vous aurez alors à entrer
* Le "BECOME password". Il s'agit du mot de passe sudo.
* le mot de passe de votre choix pour créer une base de données protégées KeepassXC qui contiendra tous les mots de passe à retenir
* le login et le mot de passe du serveur AWX qui va être installé automatiquement. C'est avec cet outils que vous allez automatiquement personnaliser les postes invités.

Une fois le script d'initialisation executé, rendez vous sur l'url de votre serveur AWX (http://127.0.0.1:8081) et connectez vous avec les identifiants que vous avez choisi.

Lors de l'installation
* les ressources sont installées dans le répertoire `/opt/clap`
* un fichier crypté par keepassXC contenant tous les mots de passe à retenir est créé à cette URI `/opt/clap/keepassXC/clap_secrets.kdbx`.
* un serveur AWX est installé. C'est lui qui permettra d'exécuter des scripts ansible sur les machines invités.

### Utilisation du serveur AWX

A FAIRE

### Désinstallation du serveur AWX

Pour désinstaller le serveur AWX il vous suffit d'executer les commandes suivantes
```
sudo docker stop awx_task awx_web awx_redis awx_postgres
sudo docker rm awx_task awx_web awx_redis awx_postgres
sudo rm -rf /opt/clap/
rm -rf ~/CLAP
```

## Initialisation des postes "invités" 

A FAIRE

## Répertoires du repo

### Racine
Le fichier bootstrap est le script qui permet d'installer automatiquement un serveur AWX sur le poste "administrateur". Les autres opérations de configuration de ce poste et des postes invités seront réalisés ensuite via l'interface du serveur AWX. 

### ansiblePaybooks
Le repertoires dans lequel sont stockés le contenu des différents playbooks.

### IsoMaker
L'embryon d'un projet pour créer des clés USB installables d'une distribution Xubuntu avec les outils préinstallés.

Pour les postes "administrateur": une installation automatique du serveur AWX lors du démarrage du serveur.

Pour les postes invités: un serveur SSH avec des accès préconfigurés pour être joignables par le serveur AWX.

## Sécurité
Il est fortement conseillé de crypter le disque dur lors de l'installation de la distribution Xubuntu sur le poste admin.
Le fichier de configuration de docker-compose garde en clair les credentials pour accéder aux BDD. Cette BDD peut contenir des données sensibles tels que les accès aux postes "invitées".