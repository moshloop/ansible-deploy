{% for group in hostvars.keys() | play_groups(groups, hostvars) %}
{% set _vars = hostvars[groups[group][0]] %}
{% for container in _vars['containers'] | default([]) %}
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{container.service}}
spec:
  replicas: {{ container.replicas | default(1) }}
  strategy: {}
  template:
    metadata:
        labels:
          app: {{container.service}}
    spec:
      containers:
        - name: {{container.service}}
          env:
{% for key in container.env %}
            - name: {{key}}
              value: {{container.env[key]}}
{% endfor %}
          image: {{docker_registry}}/{{container.image}}
          ports:
{% for port in container.ports %}
            - containerPort: {{ port.split(':')[1] }}
{% endfor %}
          resources:
            limits:
              cpu: "{{ 1024 * container.cpu | int }}m"
              memory: "{{ container.mem  | int }}Mi"
      restartPolicy: Always


{% if container.labels['elb.ports'] is defined %}
{% set elb = container.labels | sub_map('elb.') %}
{% set port = elb.ports | split(':') | first %}
{% set target_port = elb.ports | split(':') | last  %}
---
kind: Service
apiVersion: v1
metadata:
  name:  {{container.service}}
spec:
  selector:
    app:  {{container.service}}
  ports:
    - protocol: TCP
      port: {{ port }}
      targetPort: {{ target_port }}
  type: LoadBalancer
{% else %}
---
kind: Service
apiVersion: v1
metadata:
  name:  {{container.service}}
spec:
  selector:
    app:  {{container.service}}
  ports:
{% if container.ports | length > 1 %}
{% for port in container.ports %}
    - protocol: TCP
      port: {{ port.split(':')[0] }}
      targetPort:  {{ port.split(':')[1] }}
      name: "port-{{port.split(':')[0]}}"
{% endfor %}
{% else %}
    - protocol: TCP
      port: {{ container.ports[0].split(':')[0] }}
      targetPort:  {{ container.ports[0].split(':')[1] }}
{% endif %}

{% endif %}
{% endfor %}
{% endfor %}