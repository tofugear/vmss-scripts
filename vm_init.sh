#!/bin/sh
set -e

function usage
{
    echo "Usage: vm_init -g git_url -p private_key -gh git_host -gu git_user"
}

function setup_sshkey 
{
    mkdir -p ~/.ssh
    private_key=$(echo $private_key | base64 --decode); 
    keyfile=~/.ssh/$git_host.key
    echo $private_key > $keyfile

    [ -f ~/.ssh/config ] && rm ~/.ssh/config

cat >> ~/.ssh/config << EOF
Host $git_host
HostName $git_host
User $git_user
IdentityFile $keyfile
EOF

    chmod 700 ~/.ssh 
    chmod 400 ~/.ssh/*
    eval `ssh-agent`
    ssh-add

}

function execute
{
    setup_sshkey
    mkdir -p /var/deploy 

    git clone $git_url /var/deploy 

    sh /var/deploy/vm_deploy.sh
}


while [ "$1" != "" ]; do
    case $1 in
        -gh | --git-host )      shift
                                git_host=$1
                                ;;
        -gu | --git-user )      shift   
                                git_user=$1
                                ;;
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

if [ -z "$git_url" ] || [ -z "$private_key" ] || [ -z "$git_user" ] || [ -z "$git_host" ]; then
    usage    
else
    execute
fi

