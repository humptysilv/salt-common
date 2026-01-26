auditbeat:
  service.dead:
    - enable: False

sys-process/auditbeat:
  pkg.purged:
    - pkgs:
      {% if grains.os == 'Gentoo' %}
      - sys-process/auditbeat
      {% else %}
      - auditbeat
      {% endif %}
    - require:
      - service: auditbeat
