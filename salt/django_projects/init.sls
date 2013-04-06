

{% for project_key, project_args in pillar['django_projects'].iteritems() %}

base-path-{{ project_key }}:
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


project-git-{{ project_key }}:
    git.latest:
        - name: {{ project_args['repo']['url'] }}
        - rev: {{ project_args['repo']['revision'] }}
        - target: {{ project_args['base_path'] }}/{{ project_args['project_name'] }}
        - force: true
        

project-root-{{ project_key }}:
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
            - git: project-git-{{ project_key }}


venv_directory-{{ project_key }}:
    file:
        - directory
        - name: {{ project_args['virtualenv_path'] }}
        - makedirs: true


{{ project_args['virtualenv_path'] }}:
    virtualenv.manage:
        - requirements: {{ project_args['base_path'] }}/{{ project_args['project_name'] }}/{{ project_args['pip-requirements-file'] }}
        - clear: false
        - require:
            - file.directory: venv_directory-{{ project_key }}


uwsgi-app-{{ project_key }}:
    file.managed:
        - name: /etc/uwsgi/apps-available/{{ project_args['project_name'] }}.ini
        - source: salt://django_projects/uwsgi_app.ini
        - user: www-data
        - group: www-data
        - mode: 755
        - template: jinja
        - context:
            project_path: {{ project_args['base_path'] }}/{{ project_args['project_name'] }}
            max_requests: {{ project_args['uwsgi']['max_requests'] }}
            virtualenv_path: {{ project_args['virtualenv_path'] }}
            project_name: {{ project_args['project_name'] }}
            harakiri: {{ project_args['uwsgi']['harakiri'] }}
            django_settings_module: {{ project_args['uwsgi']['django_settings_module'] }}
            processes: {{ project_args['uwsgi']['processes'] }}

        

enable-uwsgi-app-{{ project_key }}:
    file.symlink:
        - name: /etc/uwsgi/apps-enabled/{{ project_args['project_name'] }}.ini
        - target: /etc/uwsgi/apps-available/{{ project_args['project_name'] }}.ini
        - force: false



nginx-site-{{ project_key }}:
    file.managed:
        - name: /etc/nginx/sites-available/{{ project_args['project_name'] }}.conf
        - source: salt://django_project/nginx-site-{{ project_key }}.conf
        - template: jinja
        - user: www-data
        - group: www-data
        - mode: 755


enable-nginx-site-{{ project_key }}:
    file.symlink:
        - name: /etc/nginx/sites-enabled/{{ project_args['project_name'] }}.conf
        - target: /etc/nginx/sites-available/{{ project_args['project_name'] }}.conf
        - force: false


{% endfor %}
