# Original credit: https://github.com/kylemanna/docker-openvpn

# Smallest base image
FROM resin/armv7hf-debian

LABEL maintainer="Samir Syed <syed.samiruddin@gmail.com>"

RUN [ "cross-build-start" ]

# Testing: pamtester
RUN apt-get update && \
    apt-get install openvpn iptables libpam-google-authenticator pamtester

ADD ./easyrsa3 /usr/share/easy-rsa
RUN ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

# Prevents refused client connection because of an expired CRL
ENV EASYRSA_CRL_DAYS 3650

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/

RUN [ "cross-build-end" ]