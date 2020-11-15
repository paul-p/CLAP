# CLAP
CLAviers Partagés - Un système complet de gestion d'un parc d'ordinateurs en libre-service

# Générer un iso sous Ubuntu
```
# Installer docker
apt-get install -y docker.io

# Customiser une image Ubuntu 18.04 avec Docker 
git clone https://github.com/paul-p/CLAP
cd CLAP/IsoMaker
./isoBuilder
```

# Démarrer l'iso

## Avec VENTOY 
Le plus simple est d'installer VENTOY sur une clé USB qui permet de mettre les 2 images iso des poste admin et invité sur la même clé.
Voir https://www.ventoy.net


## Avec Etcher
https://www.balena.io/etcher/
```
echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61
sudo apt update
sudo apt install etcher-electron
etcher-electron
```


Les choix à implémenter à l'installation
 * Génération des clés SSH
 * Ubuntu 64bits ou 32bits

Pourquoi Ubuntu 18.04: 
* En 18.04, Xubuntu propose des iso d'installation 32 bits, compatibles avec les anciens PCs. Gnome n'est pas proposé en 32bits.
* La version Ubuntu 20.04 ne propose pas d'installation 32 bits (https://www.numetopia.fr/retour-du-support-du-32-bits-dans-ubuntu/)



