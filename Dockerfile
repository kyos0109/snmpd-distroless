FROM centos:7.5.1804 as base

ENV SNMP_VERIOSN 5.7.3

ADD net-snmp-${SNMP_VERIOSN}.tar.gz /tmp

RUN yum update -y && \
	yum install file gcc make -y && \
    yum clean all

RUN mkdir -p /usr/local/opt && \
	cd /tmp/net-snmp-${SNMP_VERIOSN} && \
	find . -type f -regex ".*\.c" -print0 | xargs -0 sed -i 's/\/proc/\/host_proc/g' && \
	./configure --prefix=/opt --disable-ipv6 --disable-snmpv1 --with-defaults && \
	make -j$(nproc) && \
	make install && \
	rm -rf /usr/local/opt/share/man

COPY snmpd.conf /opt/etc/snmp/snmpd.conf

FROM gcr.io/distroless/base

COPY --from=base /opt /opt

VOLUME /var/net-snmp

EXPOSE 161/udp 161

CMD [ "/opt/sbin/snmpd", "-f", "-Loe", "-c", "/opt/etc/snmp/snmpd.conf" ]
