# 文件说明 @link https://prometheus.io/docs/alerting/latest/configuration/#configuration-file
# example @link https://github.com/prometheus/alertmanager/blob/main/doc/examples/simple.yml

# 全局配置
global:
  resolve_timeout: 5m                   # 持续5m未接收到告警标记后，就将告警状态标记为resolved
  smtp_smarthost: 'smtp.youremail.com:465'  # 邮箱smtp服务器代理，启用SSL发信, 端口一般是465
  smtp_from: 'youralert@youremail.com'            # 发送邮箱名称
  smtp_auth_username: 'youralert@youremail.com'      # 邮箱名称
  smtp_auth_password: 'password'      # 邮箱密码或授权码
  smtp_require_tls: false

# 告警通知模板，如邮件模板等。 @link https://prometheus.io/docs/alerting/latest/notifications/
templates:

# 接收警报的处理方式，根据规则进行匹配并采取相应的操作。@link https://prometheus.io/docs/alerting/latest/configuration/#route
route:
  receiver: 'default'   # 默认的接收器名称
  group_wait: 10s   # 在组内等待所配置的时间，如果同组内，30秒内出现相同报警，在一个组内出现。
  group_interval: 1m    # 如果组内内容不变化，5m后发送。
  repeat_interval: 1h   # 发送报警间隔，如果指定时间内没有修复，则重新发送报警
  group_by: ['alertname']   # 报警分组，根据 prometheus 的 lables 进行报警分组，这些警报会合并为一个通知发送给接收器，也就是警报分组。


# 抑制器配置 @link https://prometheus.io/docs/alerting/latest/configuration/#inhibit_rule
inhibit_rules:              # 抑制规则
- source_match:             # 源标签警报触发时抑制含有目标标签的警报，在当前警报匹配 severity: 'critical'
    severity: 'critical'    # 此处的抑制匹配一定在最上面的route中配置不然，会提示找不key。
  target_match:
    severity: 'warning'     # 目标标签值正则匹配，可以是正则表达式如: ".*MySQL.*"
  equal: ['alertname', 'instance']  # 确保这个配置下的标签内容相同才会抑制，也就是说警报中必须有这三个标签值才会被抑制。
# 以上示例是指 如果规则执行时匹配到 equal 中的标签值，且触发了 `severity: 'critical'` 警报 ，则不会发送 `severity: 'warning'` 标签的警报。
# 这里尽量避免 source_match 与 target_match 之间的重叠，否则很难做到理解与维护，同时建议谨慎使用此功能。使用基于症状的警报时，警报之间很少需要相互依赖。

# 接收者的地址信息 @link https://prometheus.io/docs/alerting/latest/configuration/#receiver
receivers:
- name: 'default'   # 与route 中 receiver 对应
  email_configs:
  - to: 'yourreceiver@youremail.com'
    send_resolved: true
  # webhook_configs:
  # - url: 'http://dingtalk:8060/dingtalk/webhook/send'
  #   send_resolved: true