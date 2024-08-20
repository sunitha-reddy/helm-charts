openstack:
  - name: default
    interval: 120
    compute_interface: internal
    ha_interface: internal
    settings:
      username: masakari
      password: {{ required ".Values.global.masakari_service_password is missing" .Values.global.masakari_service_password }}
      domain_name: default
      project_domain_name: default
      project_name: service
      auth_url: http://keystone:5000
    collectors:
      - name: storage exporter
        type: prometheus
        interval: 30
        endpoint: http://prometheus-storage.infra-monitoring:9090
        metrics:
          - name: nfs idle time
            mapping: host "host_ip" == attribute "client_ip"
            query:
              query: netapp_nfs_clients_idle_duration{volume="nova_001"}
    monitors:
      - name: nfs idle time
        assert: metric("storage exporter", "nfs idle time") <= 60
        notification:
          event: started
