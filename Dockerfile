
FROM ubuntu:xenial

RUN apt-get clean && \
  apt-get update && \
  apt-get install -y  \
    aptitude                    \
    binutils                    \
    bsdmainutils                \
    build-essential             \
    bzip2                       \
    ca-certificates             \
    coreutils                   \
    curl                        \
    findutils                   \
    gawk                        \
    git                         \
    less                        \
    libbz2-dev                  \
    libcairo2-dev               \
    libgmp-dev                  \
    libgtk-3-dev                \
    libncurses5-dev             \
    libncursesw5-dev            \
    libpango1.0-dev             \
    libreadline6-dev            \
    libreadline-dev             \
    libwebkitgtk-3.0-dev        \
    libyaml-dev                 \
    locales                     \
    make                        \
    mercurial                   \
    netcat                      \
    net-tools                   \
    nodejs-legacy               \
    patchutils                  \
    pkg-config                  \
    python-software-properties  \
    screen                      \
    software-properties-common  \
    sudo                        \
    tar                         \
    time                        \
    vim                         \
    wget                        \
    xterm                       \
    zlib1g-dev


# Set the locale - was (and may still be ) necessary for ghcjs-boot to work
# Got this originally here: # http://askubuntu.com/questions/581458/how-to-configure-locales-to-unicode-in-a-docker-ubuntu-14-04-container
#
# 2015-10-25 It seems like ghcjs-boot works without this now but when I 
# removed it, vim starting emitting error messages when using plugins 
# pathogen and vim2hs together.  
#
RUN locale-gen en_US.UTF-8  

ENV LANG=en_US.UTF-8                  \
    LANGUAGE=en_US:en                 \
    LC_ALL=en_US.UTF-8                \
    PATH="/root/.local/bin:${PATH}"   \
    CARNAP_HM=/opt/carnap             \
    TAR_OPTIONS=--no-same-owner


RUN \ 
  mkdir -p ~/.local/bin && \
  curl -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack' && \
  stack setup && \
  stack --resolver=lts-6.11 setup && \
  stack --resolver=lts-6.2 setup && \
  stack --resolver=lts-6.2 install cabal-install alex happy hscolour hsc2hs

COPY stack.yaml.ghcjs /tmp

RUN \
  mkdir /opt/ghcjs && \
  cd /opt/ghcjs && \
  cp /tmp/stack.yaml.ghcjs . && \
  stack --stack-yaml ./stack.yaml.ghcjs --allow-different-user setup

RUN "Carnap clone" : && \
  mkdir -p ${CARNAP_HM} && \
  cd ${CARNAP_HM} && \
  git clone https://github.com/phlummox/Carnap.git .

WORKDIR ${CARNAP_HM}

COPY a79* stack.yaml.ghcjs ./

RUN \
  git checkout a794e5a60e125da72ff131485fb74ea90c987a78 && \
  git apply a794e5a60e125da72ff131485fb74ea90c987a78.patch 

RUN \
  mkdir /opt/ghcjs && \
  cd /opt/ghcjs && \
  cp ${CARNAP_HM}/stack.yaml.ghcjs . && \
  stack --stack-yaml ./stack.yaml.ghcjs --allow-different-user setup

RUN \
  stack build Carnap && \
  stack --stack-yaml=stack.yaml.ghcjs build Carnap-GHCJS && \
  stack install yesod-bin


#RUN \
#  stack build Carnap-Server


