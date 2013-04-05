base:
    '*':
        - base_packages

    'roles:postgresql':
        - match: grain
        - postgresql

    'roles:elasticsearch':
        - match: grain
        - elasticsearch

    'roles:web':
        - nginx
        - uwsgi
        - python