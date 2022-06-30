FROM ubuntu:22.10

LABEL maintainer="Anders Bjørn Nedergaard <ape.anp@gmail.com>"
LABEL author="Anders Bjørn Nedergaard <ape.anp@gmail.com>"
LABEL description="A image for embedded clang compilation"

ENV USER=user

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    locales \
    apt-utils \
    build-essential \
    gdb \
    clang \
    libstdc++-12-dev \
    libstdc++-arm-none-eabi-newlib \
    llvm \
    lld \
    ssh \
    tar \
    python3 \
    sudo \
    git \
    cmake \
    wget \
    && apt-get clean

RUN git config --global http.sslverify false

RUN cd /tmp \
    && git clone --branch llvmorg-14.0.6 --depth 1 --progress https://github.com/llvm/llvm-project.git llvm-project

RUN cd /tmp/llvm-project \
    && mkdir build && cd build \
    && cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm \
    && make -j 8 && make install

RUN cd /tmp/llvm-project/compiler-rt \
    && ls \
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

RUN version=3.23.2; \
    wget --no-check-certificate -O cmake-$version-Linux-x86_64.sh https://github.com/Kitware/CMake/releases/download/v$version/cmake-$version-Linux-x86_64.sh \
 && sh cmake-$version-Linux-x86_64.sh -- --skip-license --prefix=/usr \
 && rm -f cmake-$version-Linux-x86_64.sh

RUN useradd -s /bin/bash $USER
RUN usermod -a -G sudo $USER
RUN echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER
RUN chmod 0440 /etc/sudoers.d/$USER
RUN chown -R $USER:$USER /root
RUN chmod 755 /root

RUN locale-gen en_US.UTF-8
RUN rm -f .bash_history