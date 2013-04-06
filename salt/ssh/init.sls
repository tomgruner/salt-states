/root/.ssh/known_hosts:
    file.managed:
        - user: root
        - group: root
        - mode: 700
        - makedirs: True

{% for key in pillar['ssh']['keys'] %}

/root/.ssh/{{key}}:
    file.managed:
        - source: salt://deploy/{{key}}
        - user: root
        - group: root
        - mode: 400
    require:
        - file: /root/.ssh/known_hosts

{% endfor %}

known_host_bitbucket:
    ssh_known_hosts:
        - name: bitbucket.org
        - present
        - user: root
        - fingerprint: 97:8c:1b:f2:6f:14:6b:5c:3b:ec:aa:46:46:74:7c:40

known_host_github:
    ssh_known_hosts:
        - name: github.com
        - present
        - user: root
        - fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48