FROM archlinux:latest

RUN pacman -Syu --noconfirm --noprogress pacman-contrib base-devel bash git \
    sudo openssh

RUN useradd --no-create-home build \
    && echo 'build ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/build
