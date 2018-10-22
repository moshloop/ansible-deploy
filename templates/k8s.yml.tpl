{% for group in hostvars.keys() | play_groups(groups, hostvars) %}
{% set _vars = hostvars[groups[group][0]] %}
{% for container in _vars['containers'] | default([]) %}
{% set service = container.service | default(container.image | basename) %}
{% set service = service.split(':')[0] %}
{% set env = container.env | default({}) %}
{% set ports = container.ports | default([]) %}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{service}}
spec:
  replicas: {{ container.replicas | default(1) }}
  strategy: {}
  template:
    metadata:
        labels:
          app: {{service}}
    spec:
      containers:
        - name: {{service}}
          env:
{% for key in env %}
            - name: {{key}}
              value: {{env[key]}}
{% endfor %}
          image: {{_vars.docker_registry}}/{{container.image}}
          ports:
{% for port in ports %}
            - containerPort: {{ port.split(':')[1] }}
{% endfor %}
          resources:
            requests:
              cpu: 100m
              memory: "{{ (container.mem | default(0))  | int }}Mi"
            limits:
              cpu: "{{ 1024 * (container.cpu | default(1)) | int }}m"
              memory: "{{ (container.mem | default(2048))  | int }}Mi"
      restartPolicy: Always


{% if container.labels is defined and container.labels['elb.ports'] is defined %}
{% set elb = container.labels | sub_map('elb.') %}
{% set port = elb.ports | split(':') | first %}
{% set target_port = elb.ports | split(':') | last  %}
---
kind: Service
apiVersion: v1
metadata:
  name:  {{service}}
spec:
  selector:
    app:  {{service}}
  ports:
    - protocol: TCP
      port: {{ port }}
      targetPort: {{ target_port }}
  type: LoadBalancer
{% elif ports | length > 0%}
---
kind: Service
apiVersion: v1
metadata:
  name:  {{service}}
spec:
  selector:
    app:  {{service}}
  ports:
{% if ports | length > 1 %}
{% for port in ports %}
{% set from_port = (port | string).split(':')[0] %}
{% set to_port = (port | string).split(':')[1] %}
    - protocol: TCP
      port: {{ from_port }}
      targetPort:  {{ to_port}}
      name: "port-{{from_port}}"
{% endfor %}
{% else %}
{% set from_port = (ports[0] | string).split(':')[0] %}
{% set to_port = (ports[0] | string).split(':')[1] %}
    - protocol: TCP
      port: {{ from_port }}
      targetPort:  {{ to_port }}
{% endif %}

{% endif %}
{% endfor %}
{% endfor %}