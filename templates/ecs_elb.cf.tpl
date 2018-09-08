  {{elb_name }}LB:
    Type: "AWS::ElasticLoadBalancingV2::LoadBalancer"
    Properties:
      Name: "LB-{{elb_name}}"
      Scheme:  {{ elb.scheme | default('internal') }}
      SecurityGroups:
{% for id in elb['security-groups'] | default(['default']) %}
{% if id != '' %}
          - {{sg_groups.get(id)}}
{% endif %}
{% endfor %}
      Type: {{ (elb.type | default('http')  == 'tcp') | ternary('network', 'application') }}
      Subnets:
{% for id in all_subnets | find_subnets(elb.subnet | default(subnet_name) ) | map(attribute='id') %}
        - {{id}}
{% endfor %}
{% set type = elb.type | default('http') | upper  %}
{% set target_type = type | split(':') | last %}
{% set type = type | split(':') | first %}
{% set stickiness = elb.stickiness | default(false) %}

  {{elb_name }}{{port}}Listener:
    Type: "AWS::ElasticLoadBalancingV2::Listener"
    Properties:
{% if type == 'HTTPS' %}
      Certificates:
        - CertificateArn: "{{elb['certificate-arn'] | default(default_ssl_arn)}}"
{% endif %}
      DefaultActions:
        - {TargetGroupArn: !Ref "{{elb_name }}{{port}}", Type: "forward"}
      LoadBalancerArn: !Ref "{{elb_name }}LB"
      Port: {{port}}
      Protocol: "{{type}}"

  {{elb_name }}{{port}}:
    Type: "AWS::ElasticLoadBalancingV2::TargetGroup"
    DependsOn: ["{{elb_name}}"]
    Properties:
      HealthCheckIntervalSeconds: {{elb['healthcheck-interval-seconds'] | default(30)}}
      HealthCheckPath: {{elb['healthcheck-path']  | default('/') }}
      HealthCheckPort: {{elb['healthcheck-port'] | default(target_port) }}
      HealthCheckProtocol: {{elb['healthcheck-protocol'] | default(target_type) }}
      HealthCheckTimeoutSeconds: {{elb['healthcheck-timeout-seconds'] | default(10)}}
      UnhealthyThresholdCount: {{elb['unhealthy-threshold-count'] | default(3) }}
      HealthyThresholdCount: {{elb['healthy-threshold-count'] | default(5) }}
{% if stickiness %}
      TargetGroupAttributes:
        - {Key: stickiness.enabled, Value: true}
        - {Key: stickiness.lb_cookie.duration_seconds, Value: 86400}
        - {Key: stickiness.type, Value:  lb_cookie}
{% endif %}
      Matcher:
        HttpCode: {{ elb['success-codes'] | default('200')}}
      Name: "LB-{{elb_name }}-{{target_port}}"
      Port: {{target_port}}
      Protocol: "{{target_type}}"
      VpcId: "{{vpc}}"

  {{elb_name}}DNS:
    Type: "AWS::Route53::RecordSet"
    Properties:
      HostedZoneId: "{{domain_id}}"
      Name: "{{elb_name}}.{{domain}}"
      Type: A
      AliasTarget:
        DNSName: !Join ["", [!GetAtt "{{elb_name}}LB.DNSName", "."]]
        HostedZoneId: !GetAtt "{{elb_name}}LB.CanonicalHostedZoneID"