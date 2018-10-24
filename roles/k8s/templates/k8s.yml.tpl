{% for group in (hostvars.keys() | play_groups(groups, hostvars)) %}
{% if group != 'all' and group != 'k8s' %}
{% set _vars = hostvars[groups[group][0]] %}
{% for container in _vars['containers'] | default([]) %}
{% set service = container.service %}
{% set env = container.env | default({}) %}
{% set volumes = container.volumes %}
{% set ports = container.ports  %}
{% set templates = container.templates  %}
{% set files = container.files  %}
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
            - containerPort: {{ port.to_port }}
{% endfor %}
          resources:
            requests:
              cpu: 100m
              memory: "{{ (container.mem }}Mi"
            limits:
              cpu: "{{ 1024 * (container.cpu) | int }}m"
              memory: "{{ container.mem   | int }}Mi"
          volumeMounts:
{% for volume in volumes %}
            - name: "{{ volume.split(':') | first | k8s_name }}"
              mountPath: "{{volume.split(':') | last }}"

{% endfor %}
{% for template in templates %}
            - name: {{template | k8s_name}}
              mountPath: "{{template | dirname}}"
{% endfor %}
{% for file in files %}
            - name: {{file | k8s_name}}
              mountPath: "{{file | dirname}}"
{% endfor %}

      volumes:
{% for volume in volumes %}
        - name: "{{ volume.split(':') | first  | k8s_name }}"
          hostPath:
            path: "{{volume.split(':') | last }}"
{% endfor %}
{% for template in templates %}
        - name: {{template | k8s_name}}
          configMap:
            defaultMode: 0600
            name: {{template | k8s_name}}
{% endfor %}
{% for file in files %}
        - name: {{file | k8s_name}}
          configMap:
            defaultMode: 0600
            name: {{file | k8s_name}}
{% endfor %}
      restartPolicy: Always

{% for template in templates %}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: "{{template | k8s_name}}"
data:
  "{{template | basename }}": |-
    {{ lookup('template', templates[template]) | indent(4) }}
{% endfor %}
{% for file in files %}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: "{{file | k8s_name }}"
data:
  "{{file | basename}}": |-
   {{ lookup('template', files[file]) | indent(4) }}
{% endfor %}

{% if container.labels is defined and container.labels['elb.ports'] is defined %}
{% set elb = container.labels | sub_map('elb.') %}
{% set port = elb.ports | split(':') | first %}
{% set target_port = elb.ports | split(':') | last  %}
---
kind: Service
apiVersion: v1
metadata:
  name: {{service}}
spec:
  selector:
    app: {{service}}
  ports:
    - protocol: TCP
      port: {{ port }}
      targetPort: {{ target_port }}
  type: LoadBalancer
{% elif ports | length > 0 %}
---
kind: Service
apiVersion: v1
metadata:
  name: {{service}}
spec:
  selector:
    app: {{service}}
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
      targetPort: {{ to_port }}
{% endif %}
{% endif %}
{% endfor %}
{% endif %}
{% endfor %}