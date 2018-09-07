AWSTemplateFormatVersion: 2010-09-09
Resources:

  Zone:
    Type: "AWS::Route53::HostedZone"
    Properties:
      Name: "{{cluster_name}}.{{domain}}"

  ZoneDelegation:
    Type: AWS::Route53::RecordSet
    Properties:
      HostedZoneId: "{{domain_id}}"
      Name: "{{cluster_name}}.{{domain}}"
      Type: NS
      TTL: '600'
      ResourceRecords: !GetAtt "Zone.NameServers"

  Logs:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: "/fargate/{{cluster_name}}"
      RetentionInDays: "{{log_retention | default(7) }}"

  DNS:
    Type: "AWS::ServiceDiscovery::PublicDnsNamespace"
    Properties:
      Description: "{{cluster_name}}"
      Name:  "{{cluster_name}}.{{domain}}"

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
        ImageId:  ami-a7a242da
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

                commands:
                    01_add_instance_to_cluster:
                        command: !Sub echo ECS_CLUSTER={{cluster_name}} >> /etc/ecs/ecs.config
                files:
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
          NetworkMode: awsvpc
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
              # DnsSearchDomains:
              #   - "{{cluster_name}}.{{domain}}"
              #   - "{{domain}}"
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
        ServiceRegistries:
           - RegistryArn: !GetAtt "{{container.service | cf_name }}DNS.Arn"
        TaskDefinition: !Ref "{{container.service | cf_name }}"
        DesiredCount: 1
        NetworkConfiguration:
          AwsvpcConfiguration:
            Subnets:
{% for subnet in subnets %}
              - {{subnet}}
{% endfor %}
            SecurityGroups:
{% for id in security_group_ids  %}
              - {{id}}
{% endfor %}

  {{container.service | cf_name }}DNS:
      Type: "AWS::ServiceDiscovery::Service"
      Properties:
        DnsConfig:
          DnsRecords:
            - Type: A
              TTL: 10
          NamespaceId: !Ref DNS
        Name: {{container.service}}

{% endfor %}
{% endfor %}