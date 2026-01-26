{# -*- mode: jinja2 -*- #}
# Managed by Salt
{% set users = salt.pillar.get("users:present") %}
{% for user, data in users.items() %}
 {% if 'otp_key' in data %}
HOTP/T30/6	{{ user }}	-	{{ data['otp_key'] }}
 {% endif %}
{% endfor %}
