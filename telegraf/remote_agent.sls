{% from "telegraf/map.jinja" import telegraf_grains with context %}
{%- set remote_agent = telegraf_grains.telegraf.get('remote_agent', {}) %}

{%- if remote_agent.get('enabled', False) %}

config_dir_remote_agent:
  file.directory:
    - name: {{remote_agent.dir.config}}
    - makedirs: True
    - mode: 755

config_d_dir_remote_agent:
  file.directory:
    - name: {{remote_agent.dir.config_d}}
    - makedirs: True
    - mode: 755
    - require:
      - file: config_dir_remote_agent

telegraf_config_remote_agent:
  file.managed:
    - name: {{ remote_agent.dir.config }}/telegraf.conf
    - source: salt://telegraf/files/telegraf.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - file: config_dir_remote_agent

{%- for name,values in remote_agent.get('input', {}).iteritems() %}

{%- if values is not mapping or values.get('enabled', True) %}
input_{{ name }}_remote_agent:
  file.managed:
    - name: {{ remote_agent.dir.config_d }}/input-{{ name }}.conf
    - source:
      - salt://telegraf/files/input/{{ name }}.conf
      - salt://telegraf/files/input/generic.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - file: config_d_dir_remote_agent
    - defaults:
        name: {{ name }}
        values: {{ values }}

{%- else %}
input_{{name }}_remote_agent:
  file.absent:
    - name: {{ remote_agent.dir.config_d }}/input-{{ name }}.conf
    - require:
      - file: config_d_dir_remote_agent
{%- endif %}

{%- endfor %}

{%- for name,values in remote_agent.get('output', {}).iteritems() %}

output_{{ name }}_remote_agent:
  file.managed:
    - name: {{ remote_agent.dir.config_d }}/output-{{ name }}.conf
    - source: salt://telegraf/files/output/{{ name }}.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - file: config_d_dir_remote_agent
    - defaults:
        name: {{ name }}
        values: {{ values }}

{%- endfor %}
{%- endif %}