FROM ubuntu:22.04

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \ 
    lxde \
    fcitx-mozc \
    language-pack-ja-base \
    language-pack-ja \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    sudo \
    curl \
    wget \
    git \
    autocutsel \
    tigervnc-standalone-server tigervnc-xorg-extension \
    pulseaudio \
    alsa-utils \
    fonts-noto-color-emoji \
    build-essential libssl-dev \
    firefox \
    fish 

## Z88DK
RUN sudo apt install -y build-essential \
    dos2unix \
    libboost-all-dev \
    texinfo \
    texi2html\
    libxml2-dev \
    subversion \
    bison \
    flex \
    zlib1g-dev \
    m4 \
    libtemplate-perl \
    libtemplate-plugin-yaml-perl  \
    libfile-slurp-perl \
    ragel \
    re2c

## openmsx
RUN sudo apt install -y libsdl2-dev \
    libsdl2-ttf-dev \
    libfontconfig-dev \
    libglew-dev \
    libpng-dev \
    libogg-dev \
    tcl-dev \
    libtheora-dev \
    libvorbis-dev


# Install visual code
WORKDIR /opt
RUN curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb && \
    apt install ./vscode.deb

## Z88DK
WORKDIR /opt
RUN git clone --recursive https://github.com/z88dk/z88dk.git && \
    cd z88dk && \
    export BUILD_SDCC=1 && \
    export BUILD_SDCC_HTTP=1 && \
    ./build.sh
ENV PATH $PATH:/opt/z88dk/bin
ENV ZCCCFG=/opt/z88dk/lib/config
ENV Z88DK_HOME=/opt/z88dk

## openmsx
WORKDIR /tmp
RUN git clone https://github.com/openMSX/openMSX.git && \
    cd openMSX && \
    ./configure && \
    make -j"$(nproc)" OPENMSX_TARGET_CPU=x86_64 OPENMSX_TARGET_OS=linux OPENMSX_FLAVOUR=opt staticbindist && \
    make install

# # openMSX debugger
RUN sudo apt install -y qtbase5-dev \
    qtbase5-dev-tools \
    qtchooser \
    qt5-qmake

WORKDIR /opt
RUN git clone https://github.com/openMSX/debugger
COPY others/z88dk-symbol-read-hack.patch /opt/debugger
RUN cd debugger && \
    patch -p1 < z88dk-symbol-read-hack.patch && \
    make -j"$(nproc)"


# Locale
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo 'Asia/Tokyo' > /etc/timezone
RUN locale-gen ja_JP.UTF-8 \
    && echo 'LC_ALL=ja_JP.UTF-8' > /etc/default/locale \
    && echo 'LANG=ja_JP.UTF-8' >> /etc/default/locale
ENV LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8

# User
ENV USER=teruntu \
    PASSWD=password

RUN groupadd -g 1000 developer && \
    useradd  -g      developer -G sudo -m -s /bin/bash teruntu && \
    echo $USER:$PASSWD | chpasswd
    
RUN echo 'Defaults visiblepw' >> /etc/sudoers
RUN echo $USER 'ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


# Start script
COPY start.sh /opt/
RUN chmod +x /opt/start.sh

USER ${USER}
WORKDIR /home/${USER}

# Install homebrew
RUN echo ${PASSWD} | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/${USER}/.profile
ENV PATH $PATH:/home/linuxbrew/.linuxbrew/bin

# Install asciinema
RUN brew install asciinema; exit 0

# Install anyenv and other env
RUN git clone https://github.com/anyenv/anyenv ~/.anyenv
RUN echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.bash_profile
ENV PATH $PATH:/home/${USER}/.anyenv/bin
RUN anyenv init; exit 0
RUN echo 'eval "$(anyenv init -)"' >> ~/.bash_profile
RUN yes | anyenv install --init
RUN anyenv install pyenv
RUN anyenv install nodenv

# configulation files
RUN mkdir -p ~/.config && sudo chown ${USER}:developer ~/.config
RUN mkdir ~/.config/mimeapps
COPY dot_config/mimeapps/mimeapps.list /home/${USER}/.config/mimeapps
RUN ln -s ~/.config/mimeapps/mimeapps.list ~/.config/mimeapps.list

# Add alias for visual code
RUN echo "alias code='code --no-sandbox'" >> ~/.bash_aliases

# fonts
RUN mkdir ~/.fonts && cd ~/.fonts && \
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/UbuntuMono.zip && \
    unzip UbuntuMono.zip && \
    rm UbuntuMono.zip
RUN sudo chown -R ${USER}:developer ~/.fonts

# desktop
RUN mkdir ~/Desktop && sudo chown ${USER}:developer ~/Desktop
COPY others/Desktop /home/${USER}/Desktop

# fish
RUN echo fish >> ~/.bashrc
SHELL ["/usr/bin/fish", "-c"]
RUN curl -sL https://git.io/fisher > .fisher && \ 
    source .fisher && \
    fisher install jorgebucaran/fisher && \
    fisher install oh-my-fish/theme-eclm
RUN alias --save code='code --no-sandbox'


# Command
CMD ["/opt/start.sh"]