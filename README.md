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
Puis connectez vous sur AWX http://127.0.0.1 avec les identifiants par défaut `admin` / `password`
Exécutez ensuite l'auto découverte des postes "guests"
Excutez finalement les 2 playbooks Ansible
    * Administrator
    * Guests