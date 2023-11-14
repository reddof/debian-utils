#!/bin/bash

clear

DIR=$(pwd)
MY_CHROOT=/mnt
LS=$(ls -a /mnt | grep debian-utils)

if [ "$LS" = "debian-utils" ];
	then
        	chmod -x /mnt/debian-utils
	else
		sudo chmod +x -R $DIR/*
		sudo mkdir -p /mnt/debian-utils
		sudo cp -Rn $DIR/* /mnt/debian-utils
		sudo cp -Rn $DIR/.* /mnt/debian-utils
fi

# Header template
header () { echo "
#############################################################################
##                  DEBIAN UTILITIES Script by Reddof                      ##
#############################################################################
"
}

# Pesan Error

error () { clear

read -p "

Input yang anda masukkan salah !

" input
    case $input in
		*) return
		;;
	esac
}

# Post Install
post-install () { FN_SUDO=$(ls -a /etc | grep sudoers.d)

                if [ "$FN_SUDO" = "sudoers.d" ] ;
                    then
                        echo " "
                    else
                        apt install sudo -y
                fi
                clear
                header
                read -p "

POST INSTALL MENU

1. Setting root password.
2. Konfigurasi bahasa.
3. Konfigurasi Time Zone.
4. Install Kernel.
4. Install Grub.
q. Kembali ke menu sebelumnya

Masukkan pilihan anda : " post

                    case $post in
# # Setting Root password
                        1) read -p "

Setting root password ( tekan Enter untuk lanjut )

" pass
                        case $pass in
                            *) passwd ;
                            post-install
                            ;;
                        esac
                        read -p "

Setting Password berhasil ...

" ret
                            case $ret in
                                *) post-install
                                ;;
                            esac
                        ;;
# # Setting Bahasa
                        2) FN_LOCALE=$(ls -a /usr/sbin | grep locale-gen)

                        if [ "$FN_LOCALE" = "locale-gen" ] ;
                            then
                                sudo dpkg-reconfigure locales
                                sudo echo "LANG=en_US.UTF-8" > /etc/locale.conf
                            else
                                sudo apt install locales -y
                                sudo dpkg-reconfigure locales
                                sudo echo "LANG=en_US.UTF-8" > /etc/locale.conf
                        fi ;
                        read -p "

Setting Bahasa berhasil ...

" ret
                            case $ret in
                                *) post-install
                                ;;
                            esac
                        ;;
# # Setting zona waktu
                        3) TZ_DATA=$(ls -a /usr/share | grep zoneinfo)

                        if [ "$TZ_DATA" = "zoneinfo" ] ;
                            then
                                sudo dpkg-reconfigure tzdata
                            else
                                sudo apt install tzdata -y
                                sudo dpkg-reconfigure tzdata
                        fi ;

                        read -p "

Setting Timezone berhasil ...

" ret
                            case $ret in
                                *) post-install
                                ;;
                            esac
                        ;;
# # Install kernel
                        4) read -p "

Install Kernel dan Packages Pendukung ( tekan Enter untuk lanjut )

" krn
                            case $krn in
                                *) sudo apt install linux-image-amd64 linux-headers-amd64 ntfs-3g network-manager -y ;
                                read -p "

Kernel Berhasil Diinstall ...

" ret
                                    case $ret in
                                        *) post-install
                                        ;;
                                    esac
                                ;;
                            esac
                        ;;
# # Install dan konfigurasi Grub
                        5) sudo apt install grub-efi -y ;
                        read -p "

Install Grub ke disk,

Masukan disk anda misalnya sda , sdb, sdc dll :

" disk
                        sudo grub-install /dev/$disk ;
                        sudo update-grub ;
                        read -p "

Install dan Konfigurasi Grub berhasil ...

" ret
                            case $ret in
                                *) post-install
                                ;;
                            esac
                        ;;
                        [Qq]*) return
                        ;;
                        *) error
                        post-install
                        ;;
                    esac
}

# Mount Semua yang diperlukan

mount-everything () { read -p "

Lanjut mount semua yang diperlukan yaitu sysfs, proc, dll.

[Y/n] : " yn

    case $yn in
        [Yy]*) sudo mount proc $MY_CHROOT/proc -t proc ;
            sudo mount sysfs $MY_CHROOT/sys -t sysfs ;
            sudo cp /etc/hosts $MY_CHROOT/etc/hosts ;
            sudo cp /proc/mounts $MY_CHROOT/etc/mtab ;

            read -p "

sudo mount proc $MY_CHROOT/proc -t proc ...
sudo mount sysfs $MY_CHROOT/sys -t sysfs ...
sudo cp /etc/hosts $MY_CHROOT/etc/hosts ...
sudo cp /proc/mounts $MY_CHROOT/etc/mtab ...


Mounting sudah berhasil

Keluar dari Setup ini dan masuk chroot dengan cara

Ketik : sudo chroot $MY_CHROOT /bin/bash

Kemudian setelah masuk chroot lanjut peoses 4) ...

" ret
                case $ret in
                    *) return
                    ;;
                esac
        ;;
        [Nn]*) return
        ;;
    esac

}

# Membuat file fstab
fstabgen () { read -p "

Membuat file fstab

[Y/n] : " yn
    case $yn in
        [Yy]*) sudo genfstab -U $MY_CHROOT > $DIR/fstab
        sudo mv $DIR/fstab $MY_CHROOT/etc
        FN_FSTAB=$(ls -a $MY_CHROOT/etc | grep fstab)
        if [ "$FN_FSTAB" = "fstab" ] ;
            then read -p "

File fstab berhasil dibuat ...

" ret
                case $ret in
                    *) return
                    ;;
                esac
            else read -p "

File fstab gagal dibuat, silakan keluar dan buat secara manual ...

" ret
                case $ret in
                    *) return
                    ;;
                esac
        fi
        ;;
        [Nn]*) return
        ;;
    esac
}

# Install base debian
debian-install () { read -p "

Lanjut menjalankan debootstrap untuk menginstall base debian ?

[Y/n] : " yn

    case $yn in
        [Yy]*) read -p "

Pilih Debian Edition yang ingin anda install.

pilih salah satu : stable , testing , sid .

Masukkan pilihan anda : " pilihan
            read -p "

Lanjut install Debian $pilihan ? [Y/n] : " yn
                case $yn in
                    [Yy]*) sudo debootstrap --arch amd64 --include=sudo,vim,locales,tzdata --exclude=nano $pilihan $MY_CHROOT http://kartolo.sby.datautama.net.id/debian ;
                        read -p "

Debian $pilihan sudah berhasil di install ...

" ret
                        case $ret in
                            *) return
                            ;;
                        esac
                    ;;
                    [Nn]*) return
                    ;;
                esac
        ;;
        [Nn]*) return
        ;;
    esac
}

# Install Debootstrap

debootstrap-install () { read -p "

Apakah ingin lanjut install debootstrap ?

[Y/n] : " yn

    case $yn in
        [Yy]*) FN_DEBOOTSTRAP=$(pacman -Qsq debootstrap)

                if [ "$FN_DEBOOTSTRAP" = "debootstrap" ] ;
                    then
                        echo "debootstrap sudah terinstall"
                    else
                        sudo pacman -S --asdeps debootstrap --noconfirm --overwrite "*"
                fi
            read -p "

Debootstrap sudah berhasil di install ...

" ret
                case $ret in
                    *) return
                    ;;
                esac
        ;;
        [Nn]*) return
        ;;
    esac
}

header

read -p "
MAIN MENU

1. Install Debootstrap.
2. Install System.
<<<<<<< HEAD
3. Membuat File fstab
=======
3. Membuat file fstab.
>>>>>>> 473619bd06d62a9639f89a367352838b20f3f0f4
4. Mount Semua yang Dibutuhkan.
5. Post Install.
q. Keluar

Masukkan pilihan anda : " pilihan

    case $pilihan in
        1) debootstrap-install
        ;;
        2) debian-install
        ;;
<<<<<<< HEAD
        3) fstabgen
        ;;
        4) mount-everything
        ;;
=======
	3) genfstab
	;;
        4) mount-everything
        ;;
>>>>>>> 473619bd06d62a9639f89a367352838b20f3f0f4
        5) post-install
        ;;
        [Qq]*) clear
            exit
        ;;
        *) error
        ;;
    esac

$DIR/./start.sh

