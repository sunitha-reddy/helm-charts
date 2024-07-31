# masakari.conf
[DEFAULT]
{{- include "ini_sections.default_transport_url" . }}
log_config_append = /etc/masakari/logging.ini
state_path = /var/lib/masakari
masakari_api_listen_port = {{ .Values.masakariApiPortInternal }}
auth_strategy = keystone
memcache_servers = {{ .Chart.Name }}-memcached.{{ include "svc_fqdn" . }}:{{ .Values.memcached.memcached.port | default 11211 }}

os_privileged_user_tenant = service
os_privileged_user_auth_url = {{.Values.global.keystone_api_endpoint_protocol_internal | default "http"}}://{{include "keystone_api_endpoint_host_internal" .}}:{{ .Values.global.keystone_api_port_internal | default 5000}}/v3
os_privileged_user_name = {{ .Values.global.masakari_service_user | default "masakari" }}
os_privileged_user_password = {{ required ".Values.global.masakari_service_password is missing" .Values.global.masakari_service_password }}

{{- include "ini_sections.logging_format" . }}

[database]
{{- include "ini_sections.database_options_mysql" . }}


{{- include "osprofiler" . }}

[oslo_concurrency]
lock_path = /var/lib/masakari/tmp

[keystone_authtoken]
auth_type = v3password
auth_version = v3
auth_interface = internal
www_authenticate_uri = https://{{include "keystone_api_endpoint_host_public" .}}/v3
auth_url = {{.Values.global.keystone_api_endpoint_protocol_internal | default "http"}}://{{include "keystone_api_endpoint_host_internal" .}}:{{ .Values.global.keystone_api_port_internal | default 5000}}/v3
user_domain_name = "{{.Values.global.keystone_service_domain | default "Default" }}"
project_name = "{{.Values.global.keystone_service_project | default "service" }}"
project_domain_name = "{{.Values.global.keystone_service_domain | default "Default" }}"
region_name = {{.Values.global.region}}
memcached_servers = {{ .Chart.Name }}-memcached.{{ include "svc_fqdn" . }}:{{ .Values.memcached.memcached.port | default 11211 }}
insecure = True
token_cache_time = 600
include_service_catalog = true
service_type = masakari
service_token_roles_required = True

[oslo_messaging_notifications]
driver = noop

[oslo_middleware]
enable_proxy_headers_parsing = true

[oslo_policy]
policy_file = /etc/masakari/policy.yaml

{{- include "ini_sections.cache" . }}

{{- include "util.helpers.valuesToIni" .Values.masakari_conf }}

[wsgi]
api_paste_config = /var/lib/openstack/etc/masakari/api-paste.ini

[host_failure]
evacuate_all_instances = true

[instance_failure]
process_all_instances = true
