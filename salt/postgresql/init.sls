# pillar/postgresql/init.sls
#
# postgresql:
#
#    users:
#        example_user:
#            password: example_password
#
#    databases:
#        martina:
#            owner: example_user
#



pg_hba.conf:
    file.managed:
        - name: /etc/postgresql/9.1/main/pg_hba.conf
        - source: salt://postgresql/pg_hba.conf
        - user: postgres
        - group: postgres
        - mode: 644
        - require:
            - pkg: postgresql-9.1


postgresql:
    pkg.installed:
        - name: postgresql-9.1
    service.running:
        - enabled: True
        - watch: 
            - file: pg_hba.conf
        - require: 
            - pkg: postgresql-9.1


postgresql-9.1:
    pkg.installed:
        - name: postgresql-9.1


postgresql-server-dev-9.1:
    pkg.installed:
        - name: postgresql-server-dev-9.1


{% for user, args in pillar['postgresql']['users'].iteritems() %}
postgres-user-{{ user }}:
    postgres_user.present:
        - name: {{ user }}
        - password: {{ args.password }}
        - runas: postgres
{% endfor %}


{% for database, args in pillar['postgresql']['databases'].iteritems() %}
postgres-database-{{ database }}:
    postgres_database.present:
        - name: {{ database }}
        - owner: {{ args.owner }}
        - require:
            - postgres_user: postgres-user-{{ args.owner }}
        - runas: postgres
{% endfor %}