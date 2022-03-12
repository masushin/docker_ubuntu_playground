FROM ubuntu:20.04

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
    fonts-noto-color-emoji \
    fish

# Install visual code
WORKDIR /opt
RUN curl -L https://go.microsoft.com/fwlink/?LinkID=760868 -o vscode.deb && \
    apt install ./vscode.deb

# Chrome
# RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# RUN apt install ./google-chrome-stable_current_amd64.deb

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

RUN mkdir ~/.config && sudo chown ${USER}:developer ~/.config
# Add alias for visual code
RUN echo "alias code='code --no-sandbox'" >> ~/.bash_aliases

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

# fonts
COPY others/fonts/UbuntuMono /home/${USER}/.fonts

# desktop
COPY lxterminal.desktop /home/${USER}/Desktop

# fish
RUN echo fish >> ~/.bashrc
SHELL ["/usr/bin/fish", "-c"]
RUN curl -sL https://git.io/fisher > .fisher && \ 
    source .fisher && \
    fisher install jorgebucaran/fisher && \
    fisher install oh-my-fish/theme-eclm


# Command
CMD ["/opt/start.sh"]