
FROM alpine:latest
MAINTAINER Silvio Fricke <silvio.fricke@gmail.com>

ENTRYPOINT ["/start.sh"]
VOLUME /data

ADD addons/nginx-server.conf /etc/nginx/conf.d/default.conf
ADD addons/start.sh /start.sh

# useable for any git references
ENV HUBZILLAVERSION master
#ENV HUBZILLA_ADDON_VERSION master


ENV HUBZILLAINTERVAL 10
env SERVERNAME 127.0.0.1


RUN set -ex \
    && apk update \
    && apk upgrade \
    && apk add \
        bash \
        curl \
        dcron \
        gd \
        nginx \
        openssl \
        php7 \
        php7-curl \
        php7-fpm \
        php7-gd \
        php7-json \
        php7-pdo_mysql \
        php7-pdo_pgsql \
        php7-openssl \
	php7-mbstring \
	php7-ctype \
	php7-session \
        php7-xml \
        php7-zip \
    && mkdir -p /run/nginx /hubzilla \
    && curl https://framagit.org/hubzilla/core/-/archive/${HUBZILLAVERSION}/core-${HUBZILLAVERSION}.tar.gz | tar -xz --strip-components=1 -C /hubzilla -f - \
#    && curl https://framagit.org/hubzilla/addons/-/archive/${HUBZILLA_ADDON_VERSION}/addons-${HUBZILLA_ADDON_VERSION}.tar.gz | tar -xz --strip-components=1 -C /hubzilla/addons -f - \
#    && /hubzilla/util/add_addon_repo https://framagit.org/hubzilla/addons.git hzaddons \
#    && /hubzilla/util/update_addon_repo hzaddons \
    && chown nginx:nginx -R /hubzilla \
    && chmod 0777 /hubzilla \
    && sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php7/php.ini \
    && chmod u+x /start.sh \
    && echo "*/###HUBZILLAINTERVAL###    *       *       *       *       cd /hubzilla; /usr/bin/php Zotlabs/Daemon/Master.php Cron" > /hubzilla-cron.txt

RUN apk add git \
	&& /hubzilla/util/add_addon_repo https://framagit.org/hubzilla/addons.git hzaddons \
	&& /hubzilla/util/update_addon_repo hzaddons

RUN apk add libmagic 
RUN apk add php-dom
