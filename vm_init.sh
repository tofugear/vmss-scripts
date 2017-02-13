#!/bin/sh

function usage
{
    echo "Usage: vm_init -g git_url -p private_key"

}

while [ "$1" != "" ]; do
    case $1 in
        -g | --git-url )        shift
                                git_url=$1
                                ;;
        -p | --private_key )    shift 
                                private_key=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

mkdir -p ~/.ssh
chmod 700 ~/.ssh 
echo $private_key > ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_ed25519
mkdir -p /var/deploy 

git clone $git_url /var/deploy 

source /var/deploy/vm_deploy.sh