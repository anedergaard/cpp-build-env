FROM --platform=$BUILDPLATFORM ubuntu:22.10

LABEL maintainer="Anders Bjørn Nedergaard <ape.anp@gmail.com>"
LABEL author="Anders Bjørn Nedergaard <ape.anp@gmail.com>"
LABEL description="A image for embedded development using clang as the default compiler"

ENV USER=user

#RUN DEBIAN_FRONTEND=noninteractive apt-get update \
#    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
#    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#    locales \
#    apt-utils \
#    build-essential \
#    gdb \
#    clang \
#    clang-tools \
#    clang-tidy \
#    clang-format \
#    libstdc++-12-dev \
#    libstdc++-arm-none-eabi-newlib \
#    llvm \
#    lld \
#    ssh \
#    tar \
#    python3 \
#    sudo \
#    git \
#    wget \
#    libssl-dev \
#    python3 \
#    python3-venv \
#    ninja-build \
#    && DEBIAN_FRONTEND=noninteractive apt-get install -y --reinstall ca-certificates \
#    && apt-get clean
#
#RUN sudo mkdir /usr/local/share/ca-certificates/cacert.org \
#    && sudo wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt \
#    && sudo update-ca-certificates \
#    && git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
#
#RUN version=v3.23.3; \
#    cd /tmp \
#    && git clone --branch $version --depth 1 --progress https://github.com/Kitware/CMake.git cmake
#
#RUN cd /tmp/cmake \
#    && ./bootstrap --prefix=/usr \
#    && make -j`nproc` && make install
#
#RUN cd /tmp \
#    && git clone --branch release-14.0.0 --depth 1 --progress https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm.git llvm-arm
#
#RUN cd /tmp/llvm-arm \
#    && ./setup.sh \
#    && . ./venv/bin/activate \
#    && build.py --use-ninja --install-dir /opt
#
#RUN useradd -s /bin/bash $USER
#RUN usermod -a -G sudo $USER
#RUN echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER
#RUN chmod 0440 /etc/sudoers.d/$USER
#RUN chown -R $USER:$USER /root
#RUN chmod 755 /root
#
#RUN locale-gen en_US.UTF-8
#RUN rm -f .bash_history
#RUN rm -rf /tmp
