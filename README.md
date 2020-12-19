# CLAP
CLAviers Partagés - Un système complet de gestion d'un parc d'ordinateurs en libre-service

# Comment l'utiliser
Installez une version de xubuntu 18.04.05 sur plusieurs PCs.
L'un sera le poste "administrateur" qui vous permettra de personnaliser, controler, surveiller et mettre à jour les autres postes dits "invités".
Configurez le même utilisateur et le même mot de passe sur tous les PCs invités.
Les postes invités sont des version de xubuntu personalisés afin d'offrir un accès libre accès.

# Bootstrap
Une fois les PCs installés. Connectez vous à la machine "administrateur" et executez ceci en ligne de commande
```
sudo apt-get install -y git && cd ~/ && git clone -b main https://github.com/paul-p/CLAP.git && cd CLAP && ./bootstrap.sh
```
Vous aurez alors à entrer
* le mot de passe de votre choix pour créer une base de données protégées KeepassXC qui contiendra tous les mots de passe à retenir
* le login et le mot de passe du serveur AWX qui va être installé automatiquement. C'est avec cet outils que vous allez automatiquement personnaliser les postes invités.

Une fois le script d'initialisation executé, rendez vous sur l'url de votre serveur AWX (http://127.0.0.1:8081) et connectez vous avec les identifiants que vous avez choisi.

Lors de l'installation
* les ressources sont installées dans le répertoire `/opt/clap`
* un fichier crypté par keepassXC contenant tous les mots de passe à retenir est créé à cette URI `/opt/clap/keepassXC/clap_secrets.kdbx`.
* un serveur AWX est installé. C'est lui qui permettra d'exécuter des scripts ansible sur les machines invités.