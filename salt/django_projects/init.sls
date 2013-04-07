

{% for project_key, project_args in pillar['django_projects'].iteritems() %}


database-user-{{project_key}}:
    postgres_user.present:
        - name: {{ project_args['settings']['database']['user'] }}
        - password: {{ project_args['settings']['database']['password'] }}
        - runas: postgres


database-{{project_key}}:
    postgres_database.present:
        - name: {{ project_args['settings']['database']['name'] }}
        - owner: {{ project_args['settings']['database']['user'] }}
        - require:
            - postgres_user: {{ project_args['settings']['database']['user'] }}
        - runas: postgres


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
        - require:
            - pkg: base_packages
        - watch_in:
            - service: uwsgi
        

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
        - source: salt://uwsgi/uwsgi_app.ini
        - user: www-data
        - group: www-data
        - mode: 755
        - require:
            - pkg: uwsgi-packages
        - template: jinja
        - context:
            project_path: {{ project_args['base_path'] }}/{{ project_args['project_name'] }}
            max_requests: {{ project_args['uwsgi']['max_requests'] }}
            home: {{ project_args['virtualenv_path'] }}
            project_name: {{ project_args['project_name'] }}
            harakiri: {{ project_args['uwsgi']['harakiri'] }} 
            processes: {{ project_args['uwsgi']['processes'] }}
            socket_file: /tmp/uwsgi.{{ project_args['project_name'] }}.sock
            penv: DJANGO_SETTINGS_MODULE={{ project_args['uwsgi']['django_settings_module'] }}
            module: django.core.handlers.wsgi:WSGIHandler()


enable-uwsgi-app-{{ project_key }}:
    file.symlink:
        - name: /etc/uwsgi/apps-enabled/{{ project_args['project_name'] }}.ini
        - target: /etc/uwsgi/apps-available/{{ project_args['project_name'] }}.ini
        - force: false
        - require:
            - pkg: uwsgi-packages


nginx-site-{{ project_key }}:
    file.managed:
        - name: /etc/nginx/sites-available/{{ project_args['project_name'] }}.conf
        - source: salt://nginx/nginx_site.conf
        - template: jinja
        - user: www-data
        - group: www-data
        - mode: 755
        - context:
            site_type: uwsgi
            uwsgi_socket_file: /tmp/uwsgi.{{ project_args['project_name'] }}.sock
            location_aliases: {{ project_args['nginx']['location_aliases'] }}
            listeners: {{ project_args['nginx']['listeners'] }}
            base_path: {{ project_args['base_path'] }}/{{ project_args['project_name'] }}


django-custom-settings-{{ project_key }}:
    file.managed:
        - name: {{ project_args['base_path'] }}/{{ project_args['project_name'] }}/{{ project_args['custom_settings_file'] }}.py
        - source: salt://django_projects/custom_settings.py
        - template: jinja
        - context:
            debug: '{{ project_args['settings']['debug'] }}'
            template_debug: '{{ project_args['settings']['template_debug'] }}'
            database:
                backend: '{{ project_args['settings']['database']['backend'] }}'
                host: '{{ project_args['settings']['database']['host'] }}'
                port: '{{ project_args['settings']['database']['port'] }}'
                name: '{{ project_args['settings']['database']['name'] }}'
                user: '{{ project_args['settings']['database']['user'] }}'
                password: '{{ project_args['settings']['database']['password'] }}'
            secret_key: '{{ project_args['settings']['secret_key'] }}'



enable-nginx-site-{{ project_key }}:
    file.symlink:
        - name: /etc/nginx/sites-enabled/{{ project_args['project_name'] }}.conf
        - target: /etc/nginx/sites-available/{{ project_args['project_name'] }}.conf
        - watch_in:
            - service: nginx


{% endfor %}



