# pillar/postgresql/init.sls
#
# postgresql:
#
#    users:
#        example_user:
#            name: some_user
#            password: example_password
#        another_user:
#            name: another_user
#            password: another_password
#
#    databases:
#        example_db1:
#            name: example_db
#            owner: example_user
#        example_db2:
#            name: another_db
#            owner: example_user
#
# Attention - 'name' is a required arg for each user and database


pg_hba.conf:
    file.managed:
        - name: /etc/postgresql/9.1/main/pg_hba.conf
        - source: salt://postgresql/pg_hba.conf
        - user: postgres
        - group: postgres
        - mode: 644
        - require:
            - pkg: postgresql-9.1


postgresql-packages:
    pkg.installed:
        - names: 
            - postgresql-9.1   
            - python-psycopg2
            - postgresql-server-dev-9.1


postgresql:
    service.running:
        - enabled: True
        - watch: 
            - file: pg_hba.conf
        - require: 
            - pkg: postgresql-packages


{% if pillar['postgresql']['users'] %}
{% for user_key, args in pillar['postgresql']['users'].iteritems() %}
postgres-user-{{args.name}}:
    postgres_user.present:
        - name: {{ args.name }}
        - password: {{ args.password }}
        - runas: postgres
{% endfor %}
{% endif %}

{% if pillar['postgresql']['databases'] %}
{% for database_key, args in pillar['postgresql']['databases'].iteritems() %}
postgres-database-{{ args.name }}:
    postgres_database.present:
        - name: {{ args.name }}
        - owner: {{ args.owner }}
        - require:
            - postgres_user: postgres-user-{{ args.owner }}
        - runas: postgres
{% endfor %}
{% endif %}