nginx:
    pkg.installed

default-nginx:
    file.absent: 
        - name: /etc/nginx/sites-enabled/default