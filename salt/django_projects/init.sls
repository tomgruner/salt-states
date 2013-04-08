

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


project-path-{{ project_key }}:
    file:
        - directory
        - name: {{ project_args['project_path'] }}
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
        - target: {{ project_args['project_path'] }}
        - force: true
        - require:
            - pkg: base_packages
            - ssh_known_hosts: github
        - watch_in:
            - service: uwsgi
        

project-root-{{ project_key }}:
    file:
        - directory
        - name: {{ project_args['project_path'] }}
        - user: www-data
        - group: www-data
        - recurse:
            - user
            - group
        - mode: 755
        - watch:
            - git: project-git-{{ project_key }}


{% for directory in project_args['create_directories'] %}

{{ project_args['project_path'] }}{{ directory}}:
    file:
        - directory
        - user: www-data
        - group: www-data
        - makedirs: true

{% endfor%}


venv_directory-{{ project_key }}:
    file:
        - directory
        - name: {{ project_args['virtualenv_path'] }}
        - makedirs: true


{{ project_args['virtualenv_path'] }}:
    virtualenv.manage:
        - requirements: {{ project_args['project_path'] }}/{{ project_args['pip-requirements-file'] }}
        - clear: false
        - require:
            - file.directory: venv_directory-{{ project_key }}


uwsgi-app-{{ project_key }}:
    file.managed:
        - name: /etc/uwsgi/apps-available/{{ project_key }}.ini
        - source: salt://uwsgi/uwsgi_app.ini
        - user: www-data
        - group: www-data
        - mode: 755
        - require:
            - pkg: uwsgi-packages
        - template: jinja
        - context:
            project_path: {{ project_args['project_path'] }}
            max_requests: {{ project_args['uwsgi']['max_requests'] }}
            home: {{ project_args['virtualenv_path'] }}
            project_name: {{ project_key }}
            harakiri: {{ project_args['uwsgi']['harakiri'] }} 
            processes: {{ project_args['uwsgi']['processes'] }}
            socket_file: /tmp/uwsgi.{{ project_key }}.sock
            penv: DJANGO_SETTINGS_MODULE={{ project_args['uwsgi']['django_settings_module'] }}
            module: django.core.handlers.wsgi:WSGIHandler()


enable-uwsgi-app-{{ project_key }}:
    file.symlink:
        - name: /etc/uwsgi/apps-enabled/{{ project_key }}.ini
        - target: /etc/uwsgi/apps-available/{{ project_key }}.ini
        - force: false
        - require:
            - pkg: uwsgi-packages


nginx-site-{{ project_key }}:
    file.managed:
        - name: /etc/nginx/sites-available/{{ project_key }}.conf
        - source: salt://nginx/nginx_site.conf
        - template: jinja
        - user: www-data
        - group: www-data
        - mode: 755
        - require:
            - pkg: nginx-packages
        - context:
            site_type: uwsgi
            uwsgi_socket_file: /tmp/uwsgi.{{ project_key }}.sock
            location_aliases: {{ project_args['nginx']['location_aliases'] }}
            listeners: {{ project_args['nginx']['listeners'] }}
            base_path: {{ project_args['project_path'] }}


enable-nginx-site-{{ project_key }}:
    file.symlink:
        - name: /etc/nginx/sites-enabled/{{ project_key }}.conf
        - target: /etc/nginx/sites-available/{{ project_key }}.conf
        - watch_in:
            - service: nginx
        - require:
            - pkg: nginx-packages



django-custom-settings-{{ project_key }}:
    file.managed:
        - name: {{ project_args['project_path'] }}/{{ project_args['custom_settings_file'] }}
        - source: salt://django_projects/custom_settings.py
        - template: jinja
        - require: 
            - git: project-git-{{ project_key }}
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


{% endfor %}



