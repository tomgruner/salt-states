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
        - match: grain
        - nginx
        - uwsgi
        - python
        - ssh
        - django_projects