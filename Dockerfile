# Usage examples in README

FROM akorn/luarocks:luajit2.1-alpine

RUN apk add --no-cache --virtual .build-deps gcc libc-dev libressl-dev \
	&& luarocks install copas && luarocks install dkjson && luarocks install luasec \
	&& apk del .build-deps

CMD ["lua"]
