# This is kickstart file which defines options for auto configuration
# Script Kickstart pour installation automatisée
# de (U|Xu|Ku)buntu 10.04 LTS par le réseau
#
# Options d'appel :
#  machine=nom_de_machine (obligatoire)
#    abandon de l'installation si non fourni
#  utilisateur=nom_d_utilisateur (facultatif)
#    = "Utilisateur_par_defaut" si non fourni
#  login=login_utilisateur (facultatif)
#    = $machine si non fourni
#  mdp=mot_de_passe_utilisateur (facultatif)
#    = "temporaire" si non fourni
#  mdp_vino=mot_de_passe_prise_de_controle (facultatif)
#    = $mdp si non fourni
#  distrib=[ubuntu|xubuntu] (facultatif, ubuntu par défaut)
#  aformat=non (facultatif, oui par défaut)
#  reboot=oui (facultatif, non par défaut)
#    redémarrage en fin d'installation si fourni
 
# Langue à utiliser pour l'installation et le système
lang fr_FR
 
# Modules de langue à installer
langsupport fr_FR
 
# Clavier
keyboard fr
 
# Souris
mouse
 
# Fuseau horaire
timezone --utc Europe/Paris
 
# Mot de passe Root (pas de mot de passe pour root par défaut sous Ubuntu)
rootpw --disabled
 
# Utilisateur de départ - config en section %pre
%include /tmp/user_conf
 
# Redémarrage après installation si demandé - config en section pre%
%include /tmp/reboot_conf
 
# Installation en mode texte
text
 
# Installation de l'OS plutôt que mise à jour
install
 
# Adresse du dépot local pour installation par le réseau
#url --url http://mon_serveur_local/ubuntu/
 
# Configuration du chargeur de démarrage
bootloader --location=mbr
 
# Destruction des tables de partitions invalides
zerombr yes
 
# Supression puis définition des partitions si demandé
%include /tmp/part_conf
 
# Définition des options d'authentification pour le système
auth  --useshadow  --enablemd5
 
# Configuration du réseau
%include /tmp/network_conf
 
# Configuration du pare-feu
firewall --disabled
 
# Ne pas configurer X pour le système
skipx
 
# Installation des paquets supplémentaires
%packages --resolvedeps
%include /tmp/paquets_conf
 
%pre
 
# Lecture et mise en variables des paramètres d'installation 
set -- `cat /proc/cmdline`
for I in $*; do case "$I" in *=*) eval $I;; esac; done
 
if [ -z "$machine" ]; then
    echo "Variable 'machine' non renseignée !"
    echo "Abandon de l'installation !"
    echo "Redémarrage dans 5 secondes !"
    sleep 5
    reboot
fi
 
if [ -z "$utilisateur" ]; then
    utilisateur="Utilisateur_par_defaut"
fi
 
if [ -z "$login" ]; then
    login=$machine
fi
 
if [ -z "$mdp" ]; then
    mdp="temporaire"
fi
 
if [ -z "$mdp_vino" ]; then
    mdp_vino=$mdp
fi
 
if [ "$distrib" != "xubuntu" ]; then
    distrib="ubuntu"
fi
 
if [ "$aformat" != "non" ]; then
    aformat="oui"
fi
 
if [ "$reboot" != "oui" ]; then
    reboot="non"
fi
 
echo "-------------------------------------------------"
echo "              Résumé d\'installation"
echo "-------------------------------------------------"
echo " "
echo " "
echo "-------------------------------------------------"
echo "    Nom de la machine     = $machine"
echo "    Nom de l\'utilisateur  = $utilisateur"
echo "    Login                 = $login"
echo "    Mot de passe          = $mdp"
echo "    Mot de passe Vino     = $mdp_vino"
echo "    Distribution          = $distrib"
echo "    Formatage automatique = $aformat"
echo "    Reboot après install. = $reboot"
echo "-------------------------------------------------"
echo " "
echo " "
echo "-------------------------------------------------"
echo "    L\'installation écrasera irrémédiablement"
echo "    toutes les données du disque !"
echo " "
echo "    Redémarrer la machine avant 30 secondes"
echo "    pour annuler l'installation !"
echo "--------------------------------------------------"
echo " "
echo " "
echo " "
sleep 30
 
# Configuration de l'utilisateur
echo "user $login --fullname $utilisateur --password $mdp" > /tmp/user_conf
 
# Gestion du reboot si demandé
if [ "$reboot" == "oui" ]; then
    echo "reboot" > /tmp/reboot_conf
fi
 
# Gestion des partitions si demandé
if [ "$aformat" == "oui" ]; then
    cat > /tmp/part_conf << eof
        # Suppression des partitions du système
        clearpart --all --initlabel
        # Définition des partitions
        part swap --size 1024 --fstype swap --asprimary
        part / --size 1024 --fstype ext3 --asprimary --grow
    eof
fi
 
# Configuration réseau (paramètre '--hostname=" ne fonctionne pas)
echo "network --bootproto dhcp --device=eth0" > /tmp/network_conf
 
# Configuration des paquets à installer
if [ "$distrib" == "xubuntu" ]; then
    cat > /tmp/paquets_conf << eof
        @ xubuntu-desktop
        bsd-mailx
        cups-pdf
        icedtea6-plugin
        ntp
        numlockx
        ocsinventory-agent
        openoffice.org
        smbfs
        ssh
        ssmtp
        #ttf-mscorefonts-installer
        vino
    eof
else
    cat > /tmp/paquets_conf << eof
        @ ubuntu-desktop
        bsd-mailx
        cups-pdf
        icedtea6-plugin
        ntp
        ocsinventory-agent
        smbfs
        ssh
        ssmtp
        thunderbird-locale-fr
        #ttf-mscorefonts-installer
    eof
fi
 
%post --nochroot
 
# Reprise de la définition des variables non renseignées car non conservées
if [ -z "$utilisateur" ]; then
    utilisateur="Utilisateur_par_defaut"
fi
 
if [ -z "$login" ]; then
    login=$machine
fi
 
if [ -z "$mdp" ]; then
    mdp="temp"
fi
 
if [ -z "$mdp_vino" ]; then
    mdp_vino=$mdp
fi
 
if [ "$distrib" != "xubuntu" ]; then
    distrib="ubuntu"
fi
 
if [ "$reboot" != "oui" ]; then
    reboot="non"
fi
 
# Changement de serveur du temps (selon nom de la machine)
case "$machine" in
t1* | t2*)
    sed -i 's/server ntp.ubuntu.com/server mon_serveur_temps_local/g' /target/etc/ntp.conf
    ;;
esac
 
# Changement du port ssh
sed -i 's/Port 22/Port 1234/g' /target/etc/ssh/sshd_config
 
# Mise en place de l'auto-login
if [ "$distrib" == "xubuntu" ]; then
    cat > /target/etc/gdm/custom.conf << eof
    [daemon]
    TimedLoginEnable=false
    AutomaticLoginEnable=true
    TimedLogin=$login
    AutomaticLogin=$login
    TimedLoginDelay=30
    DefaultSession=xubuntu
    eof
else
    cat > /target/etc/gdm/custom.conf << eof
    TimedLoginEnable=false
    AutomaticLoginEnable=true
    TimedLogin=$login
    AutomaticLogin=$login
    TimedLoginDelay=30
    DefaultSession=gnome
    eof
 
fi
 
# Configuration de ssmtp
cat > /target/etc/ssmtp/ssmtp.conf << eof
    root=admin@mon_domaine.com
    mailhub=mon_serveur_de_mail
    rewriteDomain=mon_domaine.com
    hostname=$machine
    FromLineOverride=YES
eof
cat > /target/etc/ssmtp/revalias << eof
    root:$machine@mon_domaine.com:mon_serveur_de_mail
    admin:$machine@mon_domaine.com:mon_serveur_de_mail
    $machine:$machine@mon_domaine.com:mon_serveur_de_mail
eof
 
# Suppression des paquets non souhaités
if [ "$distrib" == "xubuntu" ]; then
    chroot /target apt-get -y remove abiword-common
    chroot /target apt-get -y remove gnome-games-common
    chroot /target apt-get -y remove gnumeric-common
    chroot /target apt-get -y remove pidgin-data
    chroot /target apt-get -y remove transmission-common
    chroot /target apt-get -y remove xchat-common
else
    chroot /target apt-get -y remove empathy-common
    chroot /target apt-get -y remove gbrainy
    chroot /target apt-get -y remove gnome-games-common
    chroot /target apt-get -y remove gwibber-service
    chroot /target apt-get -y remove pidgin
    chroot /target apt-get -y remove pitivi
    chroot /target apt-get -y remove transmission-common
fi
 
# Modification des dépots
# suppression des dépots de sources
sed -i 's/deb-src/#deb-src/g' /target/etc/apt/sources.list
case "$machine" in
t1* | t2*)
    # passage des dépots sécurité sur mon_serveur_local
    sed -i 's/security.ubuntu.com/mon_serveur_local/g' /target/etc/apt/sources.list
    ;;
*)
    # passage des dépots sur ubuntu
    sed -i 's/mon_serveur_local/fr.archive.ubuntu.com/g' /target/etc/apt/sources.list
    ;;
esac
# ajout d'un dépot supplémentaire
case "$machine" in
t1* | t2* | t3*)
    echo 'deb http://mon_serveur_local/mon_programme/ ./' >> /target/etc/apt/sources.list
esac
 
#----------------------------------------------
# Préparation des scripts de fin d'installation
# Ces scripts seront exécutés au premier
# redémarrage de la machine
# fin_install_root appelle fin_install_user
#----------------------------------------------
# Création du fichier 'user'
if [ "$distrib" == "xubuntu" ]; then
    cat > /target/usr/bin/fin_install_user << eof
    #!/bin/bash
    # Configuration de Vino
    # La définition du mot de passe doit s'effectuer
    # avant l'autorisation de prise de controle
    gconftool-2 -s -t string /desktop/gnome/remote_access/vnc_password $(echo -n $mdp_vino | base64)
    gconftool-2 -s -t list --list-type string /desktop/gnome/remote_access/authentication_methods '[vnc]'
    gconftool-2 -s -t bool /desktop/gnome/remote_access/prompt_enabled false 
    gconftool-2 -s -t bool /desktop/gnome/remote_access/enabled true
    #
    # Création du fichier de lancement de Vino
    mkdir /home/$login/.config
    mkdir /home/$login/.config/autostart
    cat > /home/$login/.config/autostart/Vino.desktop << eof
    [Desktop Entry]
    Encoding=UTF-8
    Version=0.9.4
    Type=Application
    Name=Vino
    Comment=Vnc Server
    Exec=/usr/lib/vino/vino-server
    StartupNotify=false
    Terminal=false
    Hidden=false
    eof
 
    echo "eof" >> /target/usr/bin/fin_install_user
 
    cat >> /target/usr/bin/fin_install_user << eof
 
    # Création du fichier pour supprimer la notification de mise à jour système
    cat > /home/$login/.config/autostart/update-notifier.desktop << eof
    [Desktop Entry]
    Hidden=true
    eof
 
    echo "eof" >> /target/usr/bin/fin_install_user
else
    cat > /target/usr/bin/fin_install_user << eof
    #!/bin/bash
    # Configuration de l'interface
    # Désactivation des effets visuels
    gconftool-2 -s -t string /desktop/gnome/session/required_components/windowmanager 'metacity'
    # Modification des polices d'affichage
    gconftool-2 -s -t string /desktop/gnome/interface/font_name 'Sans 8'
    gconftool-2 -s -t string /desktop/gnome/interface/document_font_name 'Sans 8'    
    gconftool-2 -s -t string /desktop/gnome/interface/monospace_font_name 'Monospace 8'    
    gconftool-2 -s -t string /apps/nautilus/preferences/desktop_font 'Sans 8'    
    gconftool-2 -s -t string /apps/metacity/general/titlebar_font 'Sans Bold 8'    
    # Modification du thème
    gconftool-2 -s -t string /apps/metacity/general/theme 'Radiance'
    gconftool-2 -s -t string /desktop/gnome/interface/gtk_theme 'Radiance'
    gconftool-2 -s -t string /desktop/gnome/interface/icon_theme 'ubuntu-mono-light'    
    gconftool-2 -s -t string /apps/metacity/general/button_layout 'menu:minimize,maximize,close'
    # Configuration de la mise en veille
    #gconftool-2 -s -t int /apps/gnome-screensaver/idle_delay 5
    gconftool-2 -s -t bool /apps/gnome-screensaver/lock_enabled false
    # Configuration du nombre d'espaces de travail
    gconftool-2 -s -t int /apps/metacity/general/num_workspaces 1
    # Configuration de Vino
    # La définition du mot de passe doit s'effectuer
    # avant l'autorisation de prise de controle
    gconftool-2 -s -t string /desktop/gnome/remote_access/vnc_password $(echo -n $mdp_vino | base64)
    gconftool-2 -s -t list --list-type string /desktop/gnome/remote_access/authentication_methods '[vnc]'
    gconftool-2 -s -t bool /desktop/gnome/remote_access/prompt_enabled false 
    gconftool-2 -s -t bool /desktop/gnome/remote_access/enabled true
    eof
fi
 
# Création du fichier 'root'
cat > /target/usr/bin/fin_install_root << eof
#!/bin/bash
# Appel du script 'user'
su - $login -c /usr/bin/fin_install_user
# Effacement du script 'user'
rm /usr/bin/fin_install_user
# Effacement du script de fin d'installation dans cron
crontab -l > /usr/bin/tempcron
sed -i '/^@reboot /d' /usr/bin/tempcron
# ajout de la sauvegarde
case "$machine" in
t1* | t2*)
    # Génération d'une heure aléatoire entre (environ) 9h et 15h59
    heure=\\\\$(echo "scale=0;(\\\\$RANDOM/4700)+9" | bc)
    minute=\\\\$(echo "scale=0;(\\\\$RANDOM/550)" | bc)
    echo "\\\\$minute \\\\$heure * * * /usr/bin/mon_script_sauvegarde start" >> /usr/bin/tempcron
esac
crontab /usr/bin/tempcron
# Effacement du script de modification de cron
rm /usr/bin/tempcron 
/sbin/reboot
eof 
#--------------------------------------
# Fin des scripts de fin d'installation
#--------------------------------------
 
# Insertion des points de montage des partages
case "$machine" in
t1*)
    serveur="mon_serveur_1"
    ;;
t2*)
    serveur="mon_serveur_2"
    ;;
esac
 
case "$machine" in
t1* | t2*)
    mkdir /target/mnt/$serveur
    mkdir /target/mnt/$serveur/divers
    mkdir /target/mnt/$serveur/sauvegarde
    echo "//$serveur/divers   /mnt/$serveur/divers   cifs   auto,ro,password=,iocharset=utf8,codepage=cp850   0   0" >> /target/etc/fstab
    echo "//$serveur/sauvegarde   /mnt/$serveur/sauvegarde   cifs   noauto,rw,credentials=/etc/smb_sauvegarde,iocharset=utf8,codepage=cp850   0   0" >> /target/etc/fstab
 
    # Création du fichier de login pour sauvegarde
    cat > /target/etc/smb_sauvegarde << eof
    username=user_pour_sauvegarde
    password=mot_de_passe
    eof
    # Changement des droits du fichier
    chmod 600 /target/etc/smb_sauvegarde
    chown root:root /target/etc/smb_sauvegarde
 
    # Ajout du script de sauvegarde
    cat > /target/usr/bin/mon_script_sauvegarde << eof
    #!/bin/bash
    # ***** script de sauvegarde non détaillé ici *****
    eof
 
    # Ajout du fichier des exclusions (sauvegarde)
    cat > /target/etc/mon_script_sauve_excl << eof
    - cache*/
    - Cache*/
    - .cache*/
    - .Cache*/
    - /Examples
    - /.gvfs
    - lock
    - /.thumbnails/
    - trash/
    - Trash/
    - /.kde/
    - *.msf
    - *.*~
    eof
 
    # changement des droits du script de sauvegarde
    chmod 700 /target/usr/bin/mon_script_sauvegarde
    chown root:root /target/usr/bin/mon_script_sauvegarde
esac
 
# Changement des droits des scripts finaux
chmod 777 /target/usr/bin/fin_install_*
 
# Insertion du script final 'root' dans cron
chroot /target crontab -l > /target/usr/bin/tempcron
chroot /target echo "@reboot /usr/bin/fin_install_root" >> /target/usr/bin/tempcron
chroot /target crontab /usr/bin/tempcron
 
# Renommage de la machine
sed -i "s/kickseed/$machine/g" /target/etc/hostname
sed -i "s/kickseed/$machine/g" /target/etc/hosts
 
# Configuration de Ocsinventory
echo 'server=mon_serveur_local' > /target/etc/ocsinventory/ocsinventory-agent.cfg
 
# Envoi d'un mail de fin d'installation
chroot /target echo "Fin d'installation de la machine $machine de $utilisateur ($login)" | chroot /target mail -s "Fin d'installation de $machine" admin@mon_domaine.com