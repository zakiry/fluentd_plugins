# fluentd_plugins
## json_flatter
### Usage
clone and move to ```/etc/td-agent/plugin/```
### conf
example
```
<source>
  type http
  format json_flatter
  port 8888
</source>
<match td.*>
  type stdout
</match>
```
