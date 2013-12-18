#!/bin/bash
# Put this in ~/bin/ps1, and make it executable
# Then add the following line to your .bashrc or .bash_profile:
# PROMPT_COMMAND="source $HOME/bin/ps1"



# set this to whatever you want:
MAX_PWD_LENGTH=30
function shorten_pwd
{
    # This function ensures that the PWD string does not exceed $MAX_PWD_LENGTH characters
    PWD=$(pwd)

    # determine part of path within HOME, or entire path if not in HOME
    RESIDUAL=${PWD#$HOME}

    # compare RESIDUAL with PWD to determine whether we are in HOME or not
    if [ X"$RESIDUAL" != X"$PWD" ]
    then
        PREFIX="~"
    fi

    # check if residual path needs truncating to keep total length below MAX_PWD_LENGTH
    NORMAL=${PREFIX}${RESIDUAL}
    if [ ${#NORMAL} -ge $(($MAX_PWD_LENGTH)) ]
    then
        newPWD=${PREFIX}
        OIFS=$IFS
		IFS='/'
		bits=$RESIDUAL
		for x in $bits
		do
			if [ ${#x} -ge 3 ]
			then
				NEXT="/${x:0:1}"
			else
				NEXT="$x"
			fi
			newPWD="$newPWD$NEXT"
		done
		
		IFS=$OIFS
    else
        newPWD=${PREFIX}${RESIDUAL}
    fi

    # return to caller
    echo $newPWD
}


COLOR_RESET="\[\e[0m\]"
COLOR_SYS_MAIN="\[\e[01;37;45m\]"
COLOR_SYS_HIGHLIGHT="\[\e[0;30;45m\]"
COLOR_PWD="\[\e[0;30;46m\]"
COLOR_VENV="\[\033[01;37;44m\]"
COLOR_HG_DEFAULT="\[\033[00;30;42m\]"
COLOR_HG_BRANCH="\[\033[01;30;43m\]"
COLOR_GIT="\[\033[00;37m\]"


HG_BRANCH=`hg branch 2>&1`
if [[ $? == 0 ]]
then
	if [[ $HG_BRANCH == 'default' ]]
	then
	    VCS_PROMPT="$COLOR_HG_DEFAULT hg:$HG_BRANCH $COLOR_RESET"
	else
	    VCS_PROMPT="$COLOR_HG_BRANCH hg:$HG_BRANCH $COLOR_RESET"
	fi
else
    VCS_PROMPT=""
fi

GIT_BRANCH=`git branch 2>&1`
if [[ $? == 0 && -z $VCS_PROMPT ]]
then
    GIT_BRANCH=`git branch 2>&1 | grep \\* | cut -d ' ' -f 2`
    VCS_PROMPT="$COLOR_GIT git:$GIT_BRANCH $COLOR_RESET"
fi

if [[ -e $VIRTUAL_ENV ]]
then
    ENVNAME=`echo $VIRTUAL_ENV | cut -d / -f 5`
    VENV_PROMPT="$COLOR_VENV env:$ENVNAME $COLOR_RESET"
else
    VENV_PROMPT=""
fi

export PS1="$COLOR_SYS_MAIN \u$COLOR_SYS_HIGHLIGHT@$COLOR_SYS_MAIN\h $COLOR_PWD $(shorten_pwd) $VCS_PROMPT$VENV_PROMPT [\t]\n$ $COLOR_RESET"

