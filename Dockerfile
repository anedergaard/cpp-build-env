FROM --platform=$BUILDPLATFORM ubuntu:22.10

LABEL maintainer="Anders Bjørn Nedergaard <ape.anp@gmail.com>"
LABEL author="Anders Bjørn Nedergaard <ape.anp@gmail.com>"
LABEL description="A image for embedded development using clang as the default compiler"

ENV USER=user

RUN useradd -s /bin/bash $USER
RUN usermod -a -G sudo $USER
RUN echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER
RUN chmod 0440 /etc/sudoers.d/$USER
RUN chown -R $USER:$USER /root
RUN chmod 755 /root

RUN locale-gen en_US.UTF-8
RUN rm -f .bash_history
RUN rm -rf /tmp
