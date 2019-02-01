FROM openresty/openresty:bionic

ENV LUAROCKS /usr/local/openresty/luajit/bin/luarocks

RUN apt-get update && apt-get install -y libssl-dev libcurl4-openssl-dev python3-pip
RUN ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/curl

RUN $LUAROCKS install luafilesystem && \
	$LUAROCKS install lua-curl && \
	$LUAROCKS install lua-resty-http && \
	$LUAROCKS install luasec && \
	$LUAROCKS install luasocket && \
	$LUAROCKS install lua-cjson && \
	$LUAROCKS install --server=http://luarocks.org/dev ltn12

RUN pip3 install moto flask

RUN apt-get install -y zip