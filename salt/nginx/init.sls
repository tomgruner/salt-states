nginx-packages:
    pkg.installed:
        - names: 
            - nginx

nginx:
    service:
        - running


default-nginx:
    file.absent: 
        - name: /etc/nginx/sites-enabled/default