#!/bin/bash
#Wazo SUPPORT - Franck MULLER

select_mode() {

if(whiptail --title "Activation/Desactivation du mode Debug" --yesno "Voulez vous activer/désactiver le mode debug d'un service Wazo ?" --yes-button "Activer" --no-button "Désactiver"  10 70 3>&1 1>&2 2>&3) then                    
    whiptail --title "Activation/Desactivation du mode Debug" --msgbox \
"Attention l'action d'activation ou désactivation entrainera un redémarrage du/des service(s) concerné(s), ceci peut entrainer une coupure significative." 10 70 3>&1 1>&2 2>&3                                                        
    select_service 0
else
    whiptail --title "Activation/Desactivation du mode Debug" --msgbox \
"Attention l'action d'activation ou désactivation entrainera un redémarrage du/des service(s) concerné(s), ceci peut entrainer une coupure significative." 10 70 3>&1 1>&2 2>&3                                                        
    select_service 1
fi
}

select_service() {
SERVICE=$(whiptail --separate-output --title "Choix du micro-service" --checklist \
"Sélectionnez votre service pour activer le mode debug" 20 100 8 \
"wazo-auth" "Activer le mode debug sur le micro-service wazo-auth" OFF \
"wazo-plugind" "Activer le mode debug sur le micro-service wazo-plugind" OFF \
"wazo-webhookd" "Activer le mode debug sur le micro-service wazo-webhookd" OFF \
"wazo-provd" "Activer le mode debug sur le micro-service wazo-provd" OFF \
"wazo-chatd" "Activer le mode debug sur le micro-service wazo-chatd" OFF \
"wazo-confd" "Activer le mode debug sur le micro-service wazo-confd" OFF \
"wazo-dird" "Activer le mode debug sur le micro-service wazo-dird" OFF 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
    for services in $SERVICE; do active_debug $services $1; done
else
    echo "Vous avez annulé"
fi
}

active_debug(){
{
if [ $2 = 0 ]; then
   echo -e "XXX\n00\nEcriture... \nXXX"
   sleep 0.2
   echo "debug: true" > /etc/$1/conf.d/debug.yml
   echo -e "XXX\n50\nEcriture... OK \nXXX"
   sleep 0.5
   echo -e "XXX\n50\nRedémarrage du service... \nXXX"
   systemctl restart $1
else
   echo -e "XXX\n00\nEcriture... \nXXX"
   sleep 0.2
   echo "debug: false" > /etc/$1/conf.d/debug.yml
   echo -e "XXX\n50\nEcriture... Fait \nXXX"
   sleep 0.5
   echo -e "XXX\n50\nRedémarrage du service... \nXXX"
   systemctl restart $1
   echo -e "XXX\n100\nRedémarrage du service... OK \nXXX"
   sleep 0.5
fi
} | whiptail --gauge "Veuillez patienter..." 6 60 0
bye $2 $1
}

bye() {
if [ $1 = 0 ]; then
    whiptail --title "$2" --msgbox "Le mode debug est activé pour le service $2\n\nHave a nice day :-)\nWazo Support." 10 60                                                                                                           
else
    whiptail --title "$2" --msgbox "Le mode debug est désactivé pour le service $2\n\nHave a nice day :-)\nWazo Support." 10 60                                                                                                        
fi
}
select_mode
