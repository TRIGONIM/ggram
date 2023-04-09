# Usage examples in README

FROM akorn/luarocks:luajit2.1-alpine

RUN apk add --no-cache --virtual .build-deps gcc libc-dev libressl-dev \
	&& luarocks install copas \
	&& luarocks install lua-cjson \
	&& luarocks install luasec \
	&& luarocks install lua-requests-async \
	&& apk del .build-deps

ENV TZ=GMT
RUN apk add --no-cache tzdata \
	&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
	&& echo $TZ > /etc/timezone

CMD ["lua"]
