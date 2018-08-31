FROM centos:7.5.1804 as base

ENV SNMP_VERIOSN 5.7.3

# https://nchc.dl.sourceforge.net/project/net-snmp/net-snmp/5.7.3/net-snmp-5.7.3.tar.gz
ADD net-snmp-${SNMP_VERIOSN}.tar.gz /tmp

RUN yum update -y && \
	yum install file gcc make -y && \
    yum clean all

RUN mkdir -p /opt && \
	cd /tmp/net-snmp-${SNMP_VERIOSN} && \
	find . -type f -regex ".*\.c" -print0 | xargs -0 sed -i 's/\/proc/\/host_proc/g' && \
	./configure --prefix=/opt --disable-ipv6 --disable-snmpv1 --with-defaults && \
	make -j$(nproc) && \
	make install && \
	rm -rf /opt/share/man && \
	rm -rf /opt/include

COPY snmpd.conf /opt/etc/snmp/snmpd.conf

FROM gcr.io/distroless/base

COPY --from=base /opt /opt

VOLUME /var/net-snmp

EXPOSE 161/udp 161

ENTRYPOINT [ "/opt/sbin/snmpd", "-f", "-Loe", "-c", "/opt/etc/snmp/snmpd.conf" ]
