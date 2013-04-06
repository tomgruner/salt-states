
django_projects:
    
    gallery_blog:
    
        project_name: gallery_blog_site
        base_path: /usr/share/nginx/gallery_blog
        pip-requirements-file: requirements.txt
        virtualenv_path: /usr/share/nginx/gallery_blog/blog_virtual_env

        repo: 
            url: git@github.com:tomgruner/django-gallery-blog.git
            revision: master
        
        uwsgi:
            max_requests: 5000
            harakiri:  30
            django_settings_module: settings
            processes: 4