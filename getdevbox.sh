#!/bin/bash

# Usage: source <(curl -fsSL https://raw.githubusercontent.com/inkaviation/inkpublic/master/getdevbox.sh)

{ # Prevent execution if this script was only partially downloaded

bash <(curl -fsSL https://raw.githubusercontent.com/inkaviation/inkpublic/master/devbox-installer.sh)
source $HOME/.ink/devbox/bash/bashrc > /dev/null 2>&1

} # End of wrapping
