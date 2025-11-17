# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Use the existing ubuntu user
ARG USERNAME=ubuntu
ENV USERNAME=${USERNAME}

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Update and install all packages in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        vim \
        git \
        less \
        build-essential \
        cmake \
        python3 \
        python3-pip \
        python3-yaml \
        ninja-build \
        zlib1g-dev \
        openssh-client \
        sudo \
        unzip \
        dumb-init \
        libreadline-dev \
        swig \
        bison \
        python3-jinja2 \
        7zip \
        libxml2-utils \
        libxml-libxml-perl \
        libspreadsheet-writeexcel-perl \
        python3-dev \
        gcc \
        g++ \
        make \
        p7zip-full \
        rustc \
        cargo \
        libjpeg-dev \
        git-lfs \
        python3.12-venv \
        uuid-dev \
        gcc-14 \
        g++-14 \
        libtool \
        autoconf \
        automake \
        libltdl-dev \
        libffi-dev \
        libgmp3-dev \
        gnumeric \
        xsltproc \
        libstring-crc32-perl \
        lsof \
        && update-ca-certificates \
        && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 60 \
        && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 60

# Install Python packages
RUN python3 -m pip install wheel requests setuptools-rust setuptools --break-system-packages && \
    python3 -m pip install cffi --break-system-packages && \
    python3 -m pip install django numpy pandas matplotlib pyyaml py7zr paramiko lxml pyyaml six packaging beautifulsoup4 --break-system-packages && \
    python3 -m pip install GitPython colorama crcmod cryptography gitdb smmap virtualenv psutil bitstring openpyxl graphviz --break-system-packages

# Set Python 3 as default python
RUN ln -sf /usr/bin/python3 /usr/bin/python

#grant root permission to existing ubuntu user
# RUN adduser --gecos '' --disabled-password ${USERNAME} && \
#   echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

# fixuid removed - not needed since we're running as USER 1000 (ubuntu user)
# RUN ARCH="$(dpkg --print-architecture)" && \
#     curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
#     chown root:root /usr/local/bin/fixuid && \
#     chmod 4755 /usr/local/bin/fixuid && \
#     mkdir -p /etc/fixuid && \
#     printf "user: ${USERNAME}\ngroup: ${USERNAME}\n" > /etc/fixuid/config.yml

#install code-server
RUN wget -O /tmp/code-server_4.105.1_amd64.deb "https://github.com/coder/code-server/releases/download/v4.105.1/code-server_4.105.1_amd64.deb" \
 && dpkg -i /tmp/code-server_4.105.1_amd64.deb \
 && rm /tmp/code-server_4.105.1_amd64.deb

# Set shell environment
ENV SHELL=/bin/bash

EXPOSE 7860

USER 1000
ENV USER=${USERNAME}
ENV HOME=/home/${USERNAME}
WORKDIR /home/${USERNAME}

# Install nvm (Node Version Manager)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> $HOME/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $HOME/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use' >> $HOME/.profile \
    && chown -R ${USERNAME}:${USERNAME} $HOME/.nvm $HOME/.bashrc $HOME/.profile

# Install Node.js using nvm
RUN bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install 22.20.0 && nvm use 22.20.0 && nvm alias default 22.20.0' \
    && chown -R ${USERNAME}:${USERNAME} $HOME/.nvm

# Install uv (Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc \
    && echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.profile \
    && chown -R ${USERNAME}:${USERNAME} $HOME/.local

# Install Atlassian CLI (acli)
RUN curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli" \
    && chmod +x acli

# Clone the coder repository and install extensions
RUN git clone https://github.com/fenghaitao/coder.git $HOME/coder \
 && code-server --install-extension $HOME/coder/vsix/ms-python.python-2024.8.1.vsix \
 && code-server --install-extension $HOME/coder/vsix/ms-vscode.cpptools-1.7.1.vsix \
 && code-server --install-extension $HOME/coder/vsix/ms-vscode.cpptools-extension-pack-1.3.1.vsix \
 && chown -R ${USERNAME}:${USERNAME} $HOME/coder

#&& code-server --install-extension $HOME/coder/vsix/github.copilot-1.325.0.vsix \
#&& code-server --install-extension $HOME/coder/vsix/github.copilot-chat-0.27.2.vsix \

# Clone vscode-copilot-chat repository and build VSIX
RUN git clone https://github.com/fenghaitao/vscode-copilot-chat.git $HOME/vscode-copilot-chat \
    && cd $HOME/vscode-copilot-chat \
    && bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm install' \
    && bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm run compile' \
    && bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm run package -- --allow-package-secrets sendgrid' \
    && chown -R ${USERNAME}:${USERNAME} $HOME/vscode-copilot-chat

ENTRYPOINT ["dumb-init", "/usr/bin/code-server", "--bind-addr", "0.0.0.0:7860", "--auth", "none", "."]
