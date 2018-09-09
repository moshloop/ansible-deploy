AWSTemplateFormatVersion: 2010-09-09
Resources:

  Logs:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: "/fargate/{{cluster_name}}"
      RetentionInDays: "{{log_retention | default(7) }}"

  Cluster:
    Type: AWS::ECS::Cluster
    Properties:
      ClusterName: "{{cluster_name}}"

  ECSAutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
        VPCZoneIdentifier:
{% for subnet in subnets %}
          - {{subnet}}
{% endfor %}
        LaunchConfigurationName: !Ref ECSLaunchConfiguration
        MinSize: "{{cluster_size | default(3) }}"
        MaxSize: "{{cluster_size | default(3) }}"
        DesiredCapacity: "{{cluster_size | default(3) }}"
        Tags:
            - Key: Name
              Value: {{cluster_name}} ECS host
              PropagateAtLaunch: true
    CreationPolicy:
        ResourceSignal:
            Timeout: PT15M
    UpdatePolicy:
        AutoScalingRollingUpdate:
            MinInstancesInService: 1
            MaxBatchSize: 1
            PauseTime: PT15M
            SuspendProcesses:
              - HealthCheck
              - ReplaceUnhealthy
              - AZRebalance
              - AlarmNotification
              - ScheduledActions
            WaitOnResourceSignals: true

  ECSLaunchConfiguration:
    Type: AWS::AutoScaling::LaunchConfiguration
    Properties:
        AssociatePublicIpAddress: false
{% if ssh_key_name is defined %}
        KeyName: {{ssh_key_name}}
{% endif %}
        ImageId: "{{ecs_image_id | default('ami-0254e5972ebcd132c') }}"
        InstanceType: "{{ ecs_instance_type | default('c4.xlarge') }}"
        SecurityGroups:
{% for id in security_group_ids  %}
            - {{id}}
{% endfor %}
        IamInstanceProfile: arn:aws:iam::{{account_id}}:instance-profile/ecsInstanceRole
        UserData:
            "Fn::Base64": !Sub |
                #!/bin/bash
                yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
                yum install -y aws-cfn-bootstrap hibagent
                /opt/aws/bin/cfn-init -v --region ${AWS::Region} --stack ${AWS::StackName} --resource ECSLaunchConfiguration
                /opt/aws/bin/cfn-signal -e $? --region ${AWS::Region} --stack ${AWS::StackName} --resource ECSAutoScalingGroup
                /usr/bin/enable-ec2-spot-hibernation

    Metadata:
        AWS::CloudFormation::Init:
            config:
                packages:
                    yum:
                        awslogs: []
                        jq: []
                    python:
                        awscli: []

                files:
                    "/etc/ecs/ecs.config":
                        content: |
                            ECS_CLUSTER={{cluster_name}}
                    "/etc/weave/scope.config":
                        content: |
                            SERVICE_TOKEN=
                    "/etc/init/ecs.override":
                        source: https://raw.github.com/weaveworks/integrations/master/aws/ecs/packer/to-upload/ecs.override
                    "/etc/init/weave.conf":
                        source: https://raw.github.com/weaveworks/integrations/master/aws/ecs/packer/to-upload/weave.conf
                    "/etc/init/scope.conf":
                        source: https://raw.github.com/weaveworks/integrations/master/aws/ecs/packer/to-upload/scope.conf
                    "/etc/weave/run.sh":
                        source: https://raw.github.com/weaveworks/integrations/master/aws/ecs/packer/to-upload/run.sh
                        mode: '000755'
                    "/etc/weave/peers.sh":
                        source: https://raw.github.com/moshloop/weave-integrations/master/aws/ecs/packer/to-upload/peers.sh
                        mode: '000755'
                    "/usr/local/bin/weave":
                        source: https://github.com/weaveworks/weave/releases/download/v2.4.0/weave
                        mode: '000755'
                    "/usr/local/bin/scope":
                        source: https://github.com/weaveworks/scope/releases/download/v1.9.1/scope
                        mode: '000755'
                    "/etc/cfn/cfn-hup.conf":
                        mode: 000400
                        owner: root
                        group: root
                        content: !Sub |
                            [main]
                            stack=${AWS::StackId}
                            region=${AWS::Region}
                    "/etc/cfn/hooks.d/cfn-auto-reloader.conf":
                        content: !Sub |
                            [cfn-auto-reloader-hook]
                            triggers=post.update
                            path=Resources.ECSLaunchConfiguration.Metadata.AWS::CloudFormation::Init
                            action=/opt/aws/bin/cfn-init -v --region ${AWS::Region} --stack ${AWS::StackName} --resource ECSLaunchConfiguration
                    "/etc/awslogs/awscli.conf":
                        content: !Sub |
                            [plugins]
                            cwlogs = cwlogs
                            [default]
                            region = ${AWS::Region}
                    "/etc/awslogs/awslogs.conf":
                        content: !Sub |
                            [general]
                            state_file = /var/lib/awslogs/agent-state
                            [/var/log/dmesg]
                            file = /var/log/dmesg
                            log_group_name = {{cluster_name}}-/var/log/dmesg
                            log_stream_name = {{cluster_name}}
                            [/var/log/messages]
                            file = /var/log/messages
                            log_group_name = {{cluster_name}}-/var/log/messages
                            log_stream_name = {{cluster_name}}
                            datetime_format = %b %d %H:%M:%S
                            [/var/log/docker]
                            file = /var/log/docker
                            log_group_name = {{cluster_name}}-/var/log/docker
                            log_stream_name = {{cluster_name}}
                            datetime_format = %Y-%m-%dT%H:%M:%S.%f
                            [/var/log/ecs/ecs-init.log]
                            file = /var/log/ecs/ecs-init.log.*
                            log_group_name = {{cluster_name}}-/var/log/ecs/ecs-init.log
                            log_stream_name = {{cluster_name}}
                            datetime_format = %Y-%m-%dT%H:%M:%SZ
                            [/var/log/ecs/ecs-agent.log]
                            file = /var/log/ecs/ecs-agent.log.*
                            log_group_name = {{cluster_name}}-/var/log/ecs/ecs-agent.log
                            log_stream_name = {{cluster_name}}
                            datetime_format = %Y-%m-%dT%H:%M:%SZ
                            [/var/log/ecs/audit.log]
                            file = /var/log/ecs/audit.log.*
                            log_group_name = {{cluster_name}}-/var/log/ecs/audit.log
                            log_stream_name = {{cluster_name}}
                            datetime_format = %Y-%m-%dT%H:%M:%SZ
                services:
                    sysvinit:
                        cfn-hup:
                            enabled: true
                            ensureRunning: true
                            files:
                                - /etc/cfn/cfn-hup.conf
                                - /etc/cfn/hooks.d/cfn-auto-reloader.conf
                        awslogs:
                            enabled: true
                            ensureRunning: true
                            files:
                                - /etc/awslogs/awslogs.conf
                                - /etc/awslogs/awscli.conf

{% for group in hostvars.keys() | play_groups(groups, hostvars) %}
{% set _vars = hostvars[groups[group][0]] %}
{% for container in _vars['containers'] | default([]) %}
  {{container.service | cf_name }}:
      Type: AWS::ECS::TaskDefinition
      Properties:
          Cpu: "{{ 1024 * container.cpu | int }}"
          Memory: "{{ container.mem  }}"
          NetworkMode: bridge
          ExecutionRoleArn: arn:aws:iam::{{account_id}}:role/ECSTaskExecutionRole
          ContainerDefinitions:
            - Name: {{container.service | default(container.image) }}
              Image: {{docker_registry}}/{{container.image}}
              Essential: true
              LogConfiguration:
                LogDriver: awslogs
                Options:
                  "awslogs-group" : "/fargate/{{cluster_name}}"
                  "awslogs-region": "{{region}}"
                  "awslogs-stream-prefix": "{{container.service}}"
              Memory: "{{ container.mem }}"
              DnsSearchDomains:
                - weave.local
                - "{{cluster_name}}.{{domain}}"
                - "{{domain}}"
              PortMappings:
{% for port in container.ports %}
                - ContainerPort: "{{ port.split(':')[1] }}"
                  HostPort: "{{ port.split(':')[0] }}"
{% endfor %}
              Environment:
{% for key in container.env %}
                - Name: {{key}}
                  Value: {{container.env[key]}}
{% endfor %}

  {{container.service | cf_name }}Service:
      Type: AWS::ECS::Service
      Properties:
        ServiceName: "{{container.service}}"
        Cluster: !Ref Cluster
        TaskDefinition: !Ref "{{container.service | cf_name }}"
        DesiredCount: "{{ container.replicas | default(1) }}"
{% if container.labels['elb.ports'] is defined %}
{% set elb = container.labels | sub_map('elb.') %}
{% set port = elb.ports | split(':') | first %}
{% set target_port = elb.ports | split(':') | last  %}
{% set elb_name = container.service | cf_name %}
        LoadBalancers:
          - ContainerName: "{{container.service}}"
            ContainerPort: {{ target_port  }}
            TargetGroupArn: !Ref "{{elb_name}}{{port}}"
      DependsOn: ["{{elb_name }}{{port}}Listener", "{{elb_name }}{{port}}"]

{% include 'ecs_elb.cf.tpl' %}
{% endif %}


{% endfor %}
{% endfor %}