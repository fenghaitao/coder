# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

# Define username as a build argument and environment variable
ARG USERNAME=hfeng1
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

#grant root permission to user
RUN adduser --gecos '' --disabled-password ${USERNAME} && \
  echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN ARCH="$(dpkg --print-architecture)" && \
    curl -fsSL "https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-$ARCH.tar.gz" | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: ${USERNAME}\ngroup: ${USERNAME}\n" > /etc/fixuid/config.yml

#install code-server
RUN wget -O /tmp/code-server_4.102.1_amd64.deb "https://github.com/coder/code-server/releases/download/v4.102.1/code-server_4.102.1_amd64.deb"
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod a+x /usr/bin/entrypoint.sh \
 && dpkg -i /tmp/code-server_4.102.1_amd64.deb \
 && rm /tmp/code-server_4.102.1_amd64.deb

# Set shell environment
ENV SHELL=/bin/bash

EXPOSE 8080

#install extension for code-server
COPY vsix/*.vsix /tmp/vsix/
RUN code-server --install-extension /tmp/vsix/github.copilot-1.325.0.vsix \
 && code-server --install-extension /tmp/vsix/github.copilot-chat-0.27.2.vsix \
 && code-server --install-extension /tmp/vsix/ms-python.python-2024.8.1.vsix \
 && code-server --install-extension /tmp/vsix/ms-vscode.cpptools-1.7.1.vsix \
 && code-server --install-extension /tmp/vsix/ms-vscode.cpptools-extension-pack-1.3.1.vsix \
 && rm -rf /tmp/vsix

USER 1001
ENV USER=${USERNAME}
WORKDIR /nfs/site/home/${USERNAME}/coder

ENTRYPOINT ["/usr/bin/entrypoint.sh", "--bind-addr", "0.0.0.0:8080", "."]