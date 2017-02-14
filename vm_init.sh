#!/bin/bash
set -e -x 

function usage
{
    echo "Usage: vm_init -g git_url -p private_key -gh git_host -gu git_user -t deploy_type"
}

function setup_sshkey 
{
    mkdir -p ~/.ssh
    keyfile=~/.ssh/$git_host.key
    echo $private_key | base64 --decode > $keyfile
    
    [ -f ~/.ssh/config ] && rm ~/.ssh/config

cat >> ~/.ssh/config << EOF
Host $git_host
HostName $git_host
User $git_user
IdentityFile $keyfile
EOF

    chmod 700 ~/.ssh 
    chmod 400 ~/.ssh/*
    echo "run ssh-agent"
    eval `ssh-agent`

    echo "run ssh-add"
    ssh-add $keyfile

    ssh-keyscan $git_host >> ~/.ssh/known_hosts

}

function execute
{
    setup_sshkey
    mkdir -p /var/deploy 

    git clone $git_url /var/deploy 

    cp /var/deploy/authorized_keys /home/tofugear/.ssh/authorized_keys

    if [ $deploy_type = 'nginx' ]; then 
        sh /var/deploy/vm_deploy_nginx.sh
    else
        sh /var/deploy/vm_deploy_nodejs.sh        
    fi
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
        -t | --deploy-type )    shift
                                deploy_type=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ -z "$deploy_type" ]
    deploy_type='nodejs'
fi

if [ -z "$git_url" ] || [ -z "$private_key" ] || [ -z "$git_user" ] || [ -z "$git_host" ]; then
    usage    
else
    execute
fi

