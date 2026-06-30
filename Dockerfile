FROM mcr.microsoft.com/devcontainers/javascript-node:1-22-bookworm

# Added curl and unzip to handle the extension downloads
RUN apt-get update && apt-get install -y libtinfo6 git curl unzip

USER node

RUN npm install -g purescript spago purs-tidy

RUN cat <<'EOF' >> /home/node/.zshrc
parse_git_branch() {
  git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

COLOR_DEF='%f'
COLOR_USR='%F{243}'
COLOR_DIR='%F{197}'
COLOR_GIT='%F{39}'
NEWLINE=$'\n'

setopt PROMPT_SUBST
export PROMPT='${COLOR_USR}%n ${COLOR_DIR}%1~ ${COLOR_GIT}$(parse_git_branch)${COLOR_DEF}%% '
EOF

# Create the directory where VS Code Server looks for extensions
RUN mkdir -p /home/node/.vscode-server/extensions

# Download and extract the .vsix packages directly from the marketplace
RUN set -e; \
    install_ext() { \
        PUB=$1; EXT=$2; \
        URL="https://${PUB}.gallery.vsassets.io/_apis/public/gallery/publisher/${PUB}/extension/${EXT}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"; \
        curl -sL "$URL" -o /tmp/ext.zip; \
        unzip -q /tmp/ext.zip "extension/*" -d /tmp/; \
        mv /tmp/extension "/home/node/.vscode-server/extensions/${PUB}.${EXT}"; \
        rm /tmp/ext.zip; \
    }; \
    install_ext nwolverson ide-purescript; \
    install_ext dbaeumer vscode-eslint; \
    install_ext esbenp prettier-vscode;

USER root
