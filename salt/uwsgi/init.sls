
uwsgi-packages:
    pkg.installed:
        - names:
            - uwsgi 
            - uwsgi-extra 
            - uwsgi-plugin-python

uwsgi:
    service:
        - running