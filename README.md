# snmpd-distroless

snmpd config path /opt/etc/snmp/snmpd.conf

```
docker run -d -v /proc:/host_proc \
--name snmpd \
--read-only \
--privileged \
--net=host \
-p 161:161/udp \
kyos0109/snmpd-distroless
```         

---
Thanks.

https://hub.docker.com/r/really/snmpd/
