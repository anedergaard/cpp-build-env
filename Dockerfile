# Build and run:
#   docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t build-env/cpp -f Dockerfile .
#   docker run -d --cap-add sys_ptrace -p127.0.0.1:2222:22 clion/remote-ubuntu:20.04
#   ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"
#
# stop: docker stop <container_name>
#
# ssh credentials:
#   username: user
#   password: password

FROM ubuntu:20.04

LABEL maintainer="Anders Bjørn Nedergaard <ape.anp@gmail.com>"
LABEL author="Anders Bjørn Nedergaard <ape.anp@gmail.com>"
LABEL description="A distcc image for clang compilation"

ARG UID=1001
ARG GID=1001
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y ssh \
      tzdata \
      build-essential \
      gdb \
      clang \
      libstdc++-arm-none-eabi-newlib \
      llvm \
      lld \
      rsync \
      tar \
      python \
      sudo \
      ninja-build \
      git \
      distcc \
      htop \
  && apt-get clean

# CMake with Ninja Multi-Config Generator
RUN version=3.17.3; \
    wget -O cmake-$version-Linux-x86_64.sh https://github.com/Kitware/CMake/releases/download/v$version/cmake-$version-Linux-x86_64.sh \
 && sh cmake-$version-Linux-x86_64.sh -- --skip-license --prefix=/usr \
 && rm -f cmake-$version-Linux-x86_64.sh

RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_config_test_clion \
  && mkdir /run/sshd

RUN useradd -m user \
  && yes password | passwd user

RUN git clone --progress --verbose https://github.com/llvm/llvm-project.git /home/user/llvm-project
RUN cd /home/user/llvm-project/compiler-rt \
 && mkdir build \
 && cd build \
 && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
 -DCOMPILER_RT_OS_DIR="baremetal" \
 -DCOMPILER_RT_BUILD_BUILTINS=ON \
 -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
 -DCOMPILER_RT_BUILD_XRAY=OFF \
 -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
 -DCOMPILER_RT_BUILD_PROFILE=OFF \
 -DCMAKE_C_COMPILER=/usr/bin/clang \
 -DCMAKE_C_COMPILER_TARGET=armv7m-none-eabi \
 -DCMAKE_ASM_COMPILER_TARGET=armv7m-none-eabi \
 -DCMAKE_AR=/usr/bin/llvm-ar \
 -DCMAKE_NM=/usr/bin/llvm-nm \
 -DCMAKE_LINKER=/usr/bin/ld.lld \
 -DCMAKE_RANLIB=/usr/bin/llvm-ranlib \
 -DCOMPILER_RT_BAREMETAL_BUILD=ON \
 -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
 -DLLVM_CONFIG_PATH=/usr/bin/llvm-config \
 -DCMAKE_C_FLAGS="-mthumb -mfloat-abi=soft -mfpu=none" \
 -DCMAKE_ASM_FLAGS="-mthumb -mfloat-abi=soft -mfpu=none" \
 -DCOMPILER_RT_INCLUDE_TESTS=OFF \
 -DCMAKE_SYSROOT=/usr/lib/arm-none-eabi .. \
  && make -j`nproc` && make install

#CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config_test_clion"]

ENV HOME=/home/distcc
RUN useradd -s /bin/bash distcc

# Define how to start distccd by default
# (see "man distccd" for more information)
ENTRYPOINT [\
  "distccd", \
  "--daemon", \
  "--no-detach", \
  "--user", "distcc", \
  "--port", "3632", \
  "--stats", \
  "--stats-port", "3633", \
  "--log-stderr", \
  "--listen", "0.0.0.0"\
]

# 3632 is the default distccd port
# 3633 is the default distccd port for getting statistics over HTTP
EXPOSE \
  3632/tcp \
  3633/tcp

# We check the health of the container by checking if the statistics
# are served. (See
# https://docs.docker.com/engine/reference/builder/#healthcheck)
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:3633/ || exit 1