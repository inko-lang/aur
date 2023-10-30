FROM archlinux:latest

RUN pacman -Syu --noconfirm --noprogress pacman-contrib base-devel bash git \
    sudo openssh rust llvm15-libs llvm15

RUN useradd --home-dir=/home/build --create-home build \
    && echo 'build ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/build \
    && mkdir -p /home/build/.cargo \
    && echo -e "[registries.crates-io]\nprotocol = 'sparse'" \
        > /home/build/.cargo/config.toml \
    && chown -R build:build /home/build
