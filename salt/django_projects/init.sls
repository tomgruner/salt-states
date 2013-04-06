

{% for project_key, project_args in pillar['django_projects'].iteritems() %}

base-path:
    file:
        - directory
        - name: {{ project_args['base_path'] }}
        - user: www-data
        - group: www-data
        - recurse:
            - user
            - group
        - mode: 755
        - makedirs: true


project-git:
    git.latest:
        - name: {{ project_args['repo'] }}
        - rev: {{ project_args['revision'] }}
        - target: {{ project_args['base_path'] }}/{{ project_args['project_name'] }}
        - force: true
        {% if {{ project_args['repo_ssh_host'] }} %}
        - require:
            - ssh_known_hosts: {{ project_args['repo_ssh_host'] }}
        {% endif %}


project-root:
    file:
        - directory
        - name: {{ project_args['base_path'] }}/{{ project_args['project_name'] }}
        - user: www-data
        - group: www-data
        - recurse:
            - user
            - group
        - mode: 755
        - watch:
            - git: project-git


{{ project_args['venv_path'] }}:
    virtualenv.manage:
        - requirements:{{ project_args['base_path'] }}/{{ project_args['pip-requirements-file'] }}
        - clear: false
        - require:
            - pkg: python-virtualenv
            - file: project-root


uwsgi-app:
    file.managed:
        - name: /etc/uwsgi/apps-available/{{ project_args['project_name'] }}.ini
        - source: salt://django_project/{{ project_args['project_name'] }}.ini
        - template: jinja
        - user: www-data
        - group: www-data
        - mode: 755
        

enable-uwsgi-app:
    file.symlink:
        - name: /etc/uwsgi/apps-enabled/{{ project_args['project_name'] }}.ini
        - target: /etc/uwsgi/apps-available/{{ project_args['project_name'] }}.ini
        - force: false


nginx-site:
    file.managed:
        - name: /etc/nginx/sites-available/{{ project_args['project_name'] }}.conf
        - source: salt://django_project/nginx-site.conf
        - template: jinja
        - user: www-data
        - group: www-data
        - mode: 755


enable-nginx-site:
    file.symlink:
        - name: /etc/nginx/sites-enabled/{{ project_args['project_name'] }}.conf
        - target: /etc/nginx/sites-available/{{ project_args['project_name'] }}.conf
        - force: false


{% endfor %}