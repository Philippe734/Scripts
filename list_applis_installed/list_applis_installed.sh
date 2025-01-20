#! /bin/bash

# license:
# ----------------------------------------------------------------------------
#  "THE BEER-WARE LICENSE" (Revision 42):
#  <nany@forum.ubuntu-fr.org> wrote this file. As long as you retain this
#  notice you can do whatever you want with this stuff. If we meet some day,
#  and you think this stuff is worth it, you can buy me a beer in return. nany
# ----------------------------------------------------------------------------
#
# licence :
# ----------------------------------------------------------------------------
#  "LICENCE BEERWARE" (Révision 42):
#  <nany@forum.ubuntu-fr.org> a créé ce fichier. Tant que vous conservez cet
#  avertissement, vous pouvez faire ce que vous voulez de ce truc. Si on se
#  rencontre un jour et que vous pensez que ce truc vaut le coup, vous pouvez
#  me payer une bière en retour. nany
# ----------------------------------------------------------------------------

GetFlavor()
{
  echo "
  1 - Edubuntu
  2 - Kubuntu
  3 - Lubuntu
* 4 - Ubuntu
  5 - Ubuntu Budgie
  6 - Ubuntu Cinnamon
  7 - Ubuntu Kylin
  8 - Ubuntu Mate
  9 - Ubuntu Studio
 10 - Ubuntu Unity
 11 - Xubuntu
"
  while true
  do
    read -p "Entrez le numéro de votre variante (Entrée = 4) : " f
    case $f in
      "1" ) UFlavor="edubuntu" ; break ;;
      "2" ) UFlavor="kubuntu" ; break ;;
      "3" ) UFlavor="lubuntu" ; break ;;
      "" | "4" ) UFlavor="ubuntu" ; break ;;
      "5" ) UFlavor="ubuntu-budgie" ; break ;;
      "6" ) UFlavor="ubuntu-cinnamon" ; break ;;
      "7" ) UFlavor="ubuntu-kylin" ; break ;;
      "8" ) UFlavor="ubuntu-mate" ; break ;;
      "9" ) UFlavor="ubuntu-studio" ; break ;;
      "10" ) UFlavor="ubuntu-unity" ; break ;;
      "11" ) UFlavor="xubuntu" ; break ;;
      * ) echo "Entrée erronée !" ;;
    esac
  done
}

apt-mark showmanual > ~/liste-ajout-deb.txt
LANG=C snap list | awk '!/^Name/{print $1}' > ~/liste-ajout-snap.txt

UCodename=$(lsb_release -sc)
UVer=$(lsb_release -sd | awk '{print $2}')
if test -f /var/log/installer/media-info ; then
  UFlavor=$(awk '{print tolower($1)}' /var/log/installer/media-info)
else
  GetFlavor
fi

case $UFlavor in

  "ubuntu" )
    if test "$UVer" == "23.10" ; then UVer="23.10.1" ; fi
    Url="https://releases.ubuntu.com/$UVer/ubuntu-$UVer-desktop-amd64.manifest"
    ;;
    
  "ubuntu-cinnamon" | "ubuntu-kylin" )
    Url="https://cdimage.ubuntu.com/${UFlavor/-/}/releases/$UVer/release/${UFlavor/-/}-$UVer-desktop-amd64.manifest"
    ;;
    
  "ubuntu-studio" )
    Url="https://cdimage.ubuntu.com/${UFlavor/-/}/releases/$UVer/release/${UFlavor/-/}-$UVer-dvd-amd64.manifest"
    ;;
    
  "ubuntu-budgie" )
    if test "$UVer" == "23.10" ; then UVer="23.10.1" ; fi
    Url="https://cdimage.ubuntu.com/$UFlavor/releases/$UVer/release/$UFlavor-$UVer-desktop-amd64.manifest"
    ;;
    
  * )
    Url="https://cdimage.ubuntu.com/$UFlavor/releases/$UVer/release/$UFlavor-$UVer-desktop-amd64.manifest"
    ;;

esac
    
InitialDeb=( $(wget -qO- "$Url" | awk '!/snap:/{print $1}' | xargs -r apt-mark showmanual) )
InitialSnap=( $(wget -qO- "$Url" | awk '/snap:/{sub("snap:", "", $1) ; print $1}') )

for p in ${InitialDeb[@]} ; do sed -i "/^$p$/d" ~/liste-ajout-deb.txt ; done
sed -i "/linux-/d" ~/liste-ajout-deb.txt
for s in ${InitialSnap[@]} ; do sed -i "/^$s$/d" ~/liste-ajout-snap.txt ; done

echo "Les fichiers liste-ajout-deb.txt et liste-ajout-snap.txt ont été créés dans votre dossier personnel."
exit 0
