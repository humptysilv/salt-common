{% import 'pkg/common' as pkg %}
{% import 'lib/libc.sls' as libc %}
include:
  - lib.libc
  - users
  - augeas

sys-auth/oath-toolkit:
  pkg.latest:
    - pkgs:
      {% if grains.os == 'Gentoo' %}
      - {{ pkg.gen_atom('sys-auth/oath-toolkit') }}
      {% elif grains.os == 'Ubuntu' and grains.oscodename == 'noble' %}
      - libpam-oath
      - liboath0t64
      {% elif grains.os == 'Ubuntu' %}
      - libpam-oath
      - liboath0
      {% else %}
      - libpam-oath
      {% endif %}
    - require:
      {{ libc.pkg_dep() }}

/etc/security/access-passless.conf:
  file.managed:
    - source: salt://{{ slspath }}/files/access-passless.conf
    - mode: '0600'
    - user: root
    - group: root
    - require:
      - group: passless

/etc/pam.d/users.otp:
  file.managed:
    - source: salt://{{ slspath }}/files/users.otp.tpl
    - mode: '0600'
    - user: root
    - group: root
    - template: jinja
    - require:
      - pkg: sys-auth/oath-toolkit

sshd_pam1:
  augeas.change:
    - context: /files/etc/pam.d/sshd
    - changes:
      {% if grains.os == 'Gentoo' %}
      - ins 01 before "*[type='auth'][control='include'][module='system-remote-login']"
      {% elif grains.os == 'Ubuntu' and grains.oscodename == 'noble' %}
      - ins 01 before "include[.='common-auth']"
      {% endif %}
      - set /01/type auth
      - set /01/control "[success=done default=ignore]"
      - set /01/module pam_access.so
      - set /01/argument[1] "accessfile=/etc/security/access-passless.conf"
    - unless: grep -v "^#" /etc/pam.d/sshd | grep pam_access.so
    - require:
      - file: /etc/pam.d/users.otp
      - file: /etc/security/access-passless.conf

sshd_pam2:
  augeas.change:
    - context: /files/etc/pam.d/sshd
    - changes:
      {% if grains.os == 'Gentoo' %}
      - ins 02 before "*[type='auth'][control='include'][module='system-remote-login']"
      {% elif grains.os == 'Ubuntu' and grains.oscodename == 'noble' %}
      - ins 02 before "include[.='common-auth']"
      {% endif %}
      - set /02/type auth
      - set /02/control "sufficient"
      - set /02/module pam_oath.so
      - set /02/argument[1] "usersfile=/etc/pam.d/users.otp"
    - unless: grep -v "^#" /etc/pam.d/sshd | grep pam_oath.so
    - require:
      - augeas: sshd_pam1

{% if grains.selinux is defined and grains.selinux.enabled == True %}
restorecon -Frv /var/lib/pam_ssh:
  cmd.run:
    - onchanges:
      - file: /etc/pam.d/users.otp
{% endif %}
