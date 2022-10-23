# Usage examples in README

FROM akorn/luarocks:luajit2.1-alpine

RUN apk add --no-cache --virtual .build-deps gcc libc-dev libressl-dev tzdata \
	&& luarocks install copas && luarocks install dkjson && luarocks install luasec \
	&& apk del .build-deps

ENV TZ=UTC
RUN apk add --no-cache tzdata \
	&& ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
	&& echo $TZ > /etc/timezone

CMD ["lua"]
