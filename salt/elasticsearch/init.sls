openjdk-7-jre-headless:
  pkg.installed

/tmp/elasticsearch.deb:
  file:
    - managed
    - source: https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.5.deb
    - source_hash: sha1=b51e4dc55490bc03e54d7f8f2d41affc54773206

install_elasticsearch:
  cmd.run:
    - name: dpkg -i /tmp/elasticsearch.deb
    - require:
      - file: /tmp/elasticsearch.deb
      - pkg: openjdk-7-jre-headless
