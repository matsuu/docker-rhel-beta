FROM centos:7

ARG install_groups=Core
ARG target=/target

# based on https://github.com/moby/moby/blob/master/contrib/mkimage-yum.sh
RUN \
  yum install -y curl && \
  curl -sLO http://downloads.redhat.com/redhat/rhel/rhel-8-beta/rhel-8-beta.repo && \
  mkdir -m 755 "$target" && \
  mkdir -m 755 "$target"/dev && \
  mknod -m 600 "$target"/dev/console c 5 1 && \
  mknod -m 600 "$target"/dev/initctl p && \
  mknod -m 666 "$target"/dev/full c 1 7 && \
  mknod -m 666 "$target"/dev/null c 1 3 && \
  mknod -m 666 "$target"/dev/ptmx c 5 2 && \
  mknod -m 666 "$target"/dev/random c 1 8 && \
  mknod -m 666 "$target"/dev/tty c 5 0 && \
  mknod -m 666 "$target"/dev/tty0 c 4 0 && \
  mknod -m 666 "$target"/dev/urandom c 1 9 && \
  mknod -m 666 "$target"/dev/zero c 1 5 && \
  yum -c rhel-8-beta.repo --disablerepo="*" --enablerepo=rhel-8-for-`uname -m`-baseos-beta-rpms --nogpgcheck --installroot="$target" --releasever=/ --setopt=tsflags=nodocs --setopt=group_package_types=mandatory -y groupinstall "$install_groups" && \
  yum -c rhel-8-beta.repo --disablerepo="*" --enablerepo=rhel-8-for-`uname -m`-baseos-beta-rpms --installroot="$target" -y clean all && \
  ( \
    echo NETWORKING=yes && \
    echo HOSTNAME=localhost.localdomain \
  ) > "$target"/etc/sysconfig/network && \
  rm -rf "$target"/usr/{{lib,share}/locale,{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive} && \
  rm -rf "$target"/usr/share/{man,doc,info,gnome/help} && \
  rm -rf "$target"/usr/share/cracklib && \
  rm -rf "$target"/usr/share/i18n && \
  rm -rf "$target"/var/cache/yum && \
  mkdir -p --mode=0755 "$target"/var/cache/yum && \
  rm -rf "$target"/sbin/sln && \
  rm -rf "$target"/etc/ld.so.cache "$target"/var/cache/ldconfig && \
  mkdir -p --mode=0755 "$target"/var/cache/ldconfig && \
  curl -sL http://downloads.redhat.com/redhat/rhel/rhel-8-beta/rhel-8-beta.repo | sed -e "/rhel-8-for-`uname -m`/,/^enabled/s/^enabled.*/enabled = 1/" > "$target"/etc/yum.repos.d/rhel-8-beta.repo

FROM scratch

ARG target=/target

COPY --from=0 "$target"/ /

CMD ["/bin/bash"]