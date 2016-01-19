# fluentd_plugins
## json_flatter
### abstract
change nested json to flat json  
ex)  
```{"key1":"value1","key2":{"key3":"value3"},"key4":["value4","value5"]}```  
=>  
```{"key1":"value1","key2.key3":"value3","key4.1":"value4","key4.2":"value5"}```

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
