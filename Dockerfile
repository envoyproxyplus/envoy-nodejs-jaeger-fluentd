FROM envoyproxyplus/envoy-nodejs-jaeger:{{envoy}}-{{nodejs}}-{{jaeger}}-alpine

# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete' has no effect
RUN apk update && apk add --no-cache ca-certificates ruby ruby-irb ruby-etc ruby-webrick \
 && apk add --no-cache --virtual .build-deps build-base ruby-dev gnupg \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.3.10 \
 && gem install json -v 2.2.0 \
 && gem install fluentd -v {{fluentd}} \
 && gem install bigdecimal -v 1.3.5 \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

COPY fluent.conf /etc/fluent/

CMD sh -c "(fluentd -c /etc/fluent/fluent.conf &) && (envoy -c envoyproxy-config/envoy.yaml --service-cluster single-pass --log-path /tmp/envoyproxy.log &) && npm start"