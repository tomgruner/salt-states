
django_projects:
    
    gallery_blog:
    
        project_name: gallery_blog_site
        base_path: /usr/share/nginx/gallery_blog
        pip-requirements-file: requirements.txt
        virtualenv_path: /usr/share/nginx/gallery_blog/virtualenv
        custom_settings_file: local_settings

        repo: 
            url: git@github.com:tomgruner/django-gallery-blog.git
            revision: master
        
        uwsgi:
            max_requests: 5000
            harakiri:  30
            django_settings_module: settings
            processes: 4

        nginx:
            listeners:
                - 80 default
            location_aliases:
                static_files:
                    location: /static
                    directory: /static
                    expires: max
                media_files:
                    location: /media
                    directory: /media
                    expires: max

        settings:
            debug: False
            template_debug: False
            secret_key: 'super_secret_key_goes_here'
            database:
                backend: 'django.db.backends.postgresql_psycopg2'
                host: ''
                port: ''
                name: 'blog_db'
                user: 'blog_db_user'
                password: 'blog_db_pass'