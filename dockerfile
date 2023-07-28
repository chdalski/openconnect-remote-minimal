FROM debian:bookworm

ARG DEVUSER=devuser
ARG DEVUSER_UID=1000
ARG DEVUSER_GID=${DEVUSER_UID}
ARG PRE_DOCKER_PACKAGES="ca-certificates curl gnupg"
ARG DOCKER_PACKAGES="docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
ARG DEV_PACKAGES="wget unzip zip git zsh bat sudo jq ripgrep procps squid openconnect"

# Set builder shell
SHELL ["/bin/bash", "-c"]

# Setup system
RUN apt-get update \
    && apt-get install -y ca-certificates curl gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "\
    $(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y ${DOCKER_PACKAGES} ${DEV_PACKAGES} 


# Copy vpn entrypoint and proxy configuration
COPY ./vpn /vpn
RUN chmod 744 /vpn/entrypoint.sh

# Setup user
RUN groupadd --gid ${DEVUSER_GID} ${DEVUSER} \
    && useradd --uid ${DEVUSER_UID} --gid ${DEVUSER_GID} -m ${DEVUSER} \
    && echo ${DEVUSER} ALL=\(root\) NOPASSWD:SETENV: /vpn/entrypoint.sh > /etc/sudoers.d/${DEVUSER} \
    && chmod 0440 /etc/sudoers.d/${DEVUSER} \
    && usermod --shell /bin/zsh ${DEVUSER} \
    && usermod -aG docker ${DEVUSER}

USER ${DEVUSER}
WORKDIR /home/${DEVUSER}

RUN mkdir -p ${HOME}/.zsh/ \
    && git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.zsh/oh-my-zsh \
    && git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git ${HOME}/.zsh/oh-my-zsh/themes/spaceship-prompt \
    && ln -s ${HOME}/.zsh/oh-my-zsh/themes/spaceship-prompt/spaceship.zsh-theme ${HOME}/.zsh/oh-my-zsh/themes/spaceship.zsh-theme \
    && mkdir -p ${HOME}/.zsh/oh-my-zsh/custom/plugins/ \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ${HOME}/.zsh/oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && curl -s "https://get.sdkman.io" | bash \
    && chmod a+x "$HOME/.sdkman/bin/sdkman-init.sh" \
    && source "$HOME/.sdkman/bin/sdkman-init.sh" \
    && curl -s https://fnm.vercel.app/install | bash

COPY --chown=${DEVUSER}:${DEVUSER} ./home ./

ENTRYPOINT ["/usr/bin/sudo", "--preserve-env", "/vpn/entrypoint.sh"]