#!/bin/bash

{ # Prevent execution if this script was only partially downloaded

blue="\033[34m"
yellow="\033[33m"
green="\033[32m"
grey="\033[90m"
black="\033[0m"
OS=$(uname | tr '[:upper:]' '[:lower:]') # 'linux' or 'darwin'

generate_git_key() {
  echo -e "${black}Generating GitHub SSH key...${black}"
  ssh-keygen -t rsa -C "" -N "" -f $HOME/.ssh/id_rsa -q
  echo -e "${green}Private ~/.ssh/id_rsa and public ~/.ssh/id_rsa.pub keys generated!${black}"
}

validate_git_key() {
  if ! git ls-remote git@github.com:inkaviation/ink.devbox.git > /dev/null 2>&1; then
    return 1
  fi
}

get_public_git_key() {
  if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    ssh-keygen -y -f $HOME/.ssh/id_rsa >> $HOME/.ssh/id_rsa.pub
  fi

  printf "\n${blue}Go to your Github account "
  printf "Settings > SSH and GPG keys section and add your SSH key pasting the public contents\n"
  printf "https://github.com/settings/ssh/new${black}\n"

  printf "\n${yellow}Copy the public key contents from here >>>>>${black}\n"
  cat $HOME/.ssh/id_rsa.pub
  printf "${yellow}<<<<< to here${black}\n\n"

  echo -e "${blue}Also verify your GitHub account permissions with your supervisor${black}\n"
  echo -e "The installation will continue automatically after you associate"\
          "the key and have the correct permissions..."
}

fix_known_hosts() {
  touch $HOME/.ssh/known_hosts

  if ! grep -q "github.com" $HOME/.ssh/known_hosts; then
    ssh-keyscan github.com >> $HOME/.ssh/known_hosts
  fi
}

echo -e "${blue}\
    ____      __
   /  _/___  / /__
   / // __ \/ //_/
 _/ // / / / ,<
/___/_/ /_/_/|_|
${black}"

echo -e "${blue}Ink DevBox Installer${black}"

# 1. Check Git SSH key
fix_known_hosts > /dev/null 2>&1

if [ ! -f "$HOME/.ssh/id_rsa" ]; then
  generate_git_key
else
  chmod 400 $HOME/.ssh/id_rsa
  echo -e "${black}Validating existing SSH key ~/.ssh/id_rsa...${black}"
fi

validate_git_key

if [ $? -ne 0 ]; then
  get_public_git_key

  false
  while [ $? -ne 0 ]; do
    sleep 5
    validate_git_key
  done
fi

echo -e "${green}GitHub SSH key validated!${black}"

# 2. Clone ink.devbox repo
echo -e "Installing..."
INK_DEVBOX_HOME=$HOME/.ink/devbox
mkdir -p $INK_DEVBOX_HOME
rm -rf $INK_DEVBOX_HOME
git clone git@github.com:inkaviation/ink.devbox.git $INK_DEVBOX_HOME > /dev/null 2>&1
cd $INK_DEVBOX_HOME
git config --local core.fileMode false

source $INK_DEVBOX_HOME/scripts/fix-permissions

# 3. Set bashrc
case "$OS" in
  "linux")
    if ! grep -q ". ~/.ink/devbox/bash/bashrc" $HOME/.bashrc; then
      cat $INK_DEVBOX_HOME/bash/bashrc_source >> $HOME/.bashrc
    fi
  ;;
  "darwin")
    touch $HOME/.bash_profile

    if ! grep -q ". ~/.ink/devbox/bash/bashrc" $HOME/.bash_profile; then
      cat $INK_DEVBOX_HOME/bash/bashrc_source >> $HOME/.bash_profile
    fi

    touch $HOME/.zshrc

    if ! grep -q ". ~/.ink/devbox/bash/bashrc" $HOME/.zshrc; then
      cat $INK_DEVBOX_HOME/bash/bashrc_source >> $HOME/.zshrc
    fi
  ;;
esac

printf "${green}Installation complete!${black}\n"

} # End of wrapping
