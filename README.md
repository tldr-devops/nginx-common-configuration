## Nginx common useful configuration

Time track:
- Filipp Frizzy 22.67h

### Known traps

#### Cache with default settings break all client specific content
If you use fastcgi, proxy or uwsgi cache with default settings like
```
http {

    proxy_cache_path /tmp/cache levels=1:2 keys_zone=mycache:10m max_size=10g 
                inactive=60m use_temp_path=off;

    server {
        listen 80;
        proxy_cache mycache;

        location / {
            proxy_pass http://backend1;
        }

        location /some/path {
            proxy_pass http://backend2;
            proxy_cache_valid any 1m;
            proxy_cache_min_uses 3;
            proxy_cache_bypass $cookie_nocache $arg_nocache$arg_comment;
        }
    }
}
```
in both locations Nginx will cache every response. 
So if your site has some login functionality or shopping cart or whatever, 
it will be mixed and most of clients will get response with content of some other clients.

In this configuration I suggest caches only as a auxiliary tool for caching common non 200 status responses:
```
fastcgi_cache_valid 499 500 502 503 504 521 522 523 524 3s; # circuit breaker
fastcgi_cache_valid 404 15m; # cache Not Found for decrease loading to backend
fastcgi_cache_valid 301 308 1h; # cache Permanent Redirect for decrease loading to backend
fastcgi_cache_valid 302 307 5s; # cache Temporary Redirect for decrease loading to backend

# don't cache any other responses
fastcgi_cache_valid 200 0;
fastcgi_cache_valid any 0;
```
And even this one commented out in cache.conf, so you should choose yourself 
and enable it manually for whole site or some locations.

However, how we can safely enable cache for all responses?.
And use cache config like
```
fastcgi_cache_valid 401 0;
fastcgi_cache_valid any 3s;
fastcgi_cache_valid 404 15m;
fastcgi_cache_valid 301 308 1h;
fastcgi_cache_valid 200 5m;
```

1) *The easiest*  
By default, NGINX respects the Cache-Control headers from origin servers. 
It does not cache responses with Cache-Control set to Private, No-Cache, or 
No-Store or with Set-Cookie in the response header. So if your app can add `Cache-Control` 
header into every response - we are done here :) [Example](https://serverfault.com/a/815990)

2) *The most correct*  
If you app can store cache in an external cache database 
like redis or memcached, you can use Nginx 
[redis](https://github.com/openresty/redis2-nginx-module) or 
[memcached](https://nginx.org/en/docs/http/ngx_http_memcached_module.html) 
modules instead of nginx cache for both caching and speeding up your site.

3) *The most difficult*  
You can check URI and cookies by nginx itself, but this is hard 
and add a mess into your configs and risk of mistakes. There is a good example in 
the [engintron](https://github.com/engintron/engintron/blob/master/nginx/proxy_params_dynamic) configs, 
but it's under GPLv2 so I can't include it into my snippets. Also there is a little easier 
[example](https://dev.to/ale_ukr/how-to-make-nginx-cache-cookie-aware-2ffl) how to check only one cookie.

4) *Bonus: the lucky one*  
For static content locations you can just enable cache without any dancing around :)

#### [Adding add_header remove all add_header directives from parent sections](https://www.peterbe.com/plog/be-very-careful-with-your-add_header-in-nginx)

Configuration like
```
add_header Name1 Value1;

location / {
    add_header Name2 Value2;
```
After all produce only `Name2` header in response. 
So use add_header.conf include or copy all headers manually 
into sections under HTTP one.
```
include /etc/nginx/snippets/headers.conf
```

### Nginx build info

#### Docker
```
nginx version: nginx/1.17.9
built by gcc 8.3.0 (Debian 8.3.0-6)
built with OpenSSL 1.1.1d  10 Sep 2019
TLS SNI support enabled
configure arguments: 
--prefix=/etc/nginx 
--sbin-path=/usr/sbin/nginx 
--modules-path=/usr/lib/nginx/modules 
--conf-path=/etc/nginx/nginx.conf 
--error-log-path=/var/log/nginx/error.log 
--http-log-path=/var/log/nginx/access.log 
--pid-path=/var/run/nginx.pid 
--lock-path=/var/run/nginx.lock 
--http-client-body-temp-path=/var/cache/nginx/client_temp 
--http-proxy-temp-path=/var/cache/nginx/proxy_temp 
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp 
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp 
--http-scgi-temp-path=/var/cache/nginx/scgi_temp 
--user=nginx 
--group=nginx 
--with-compat 
--with-file-aio 
--with-threads 
--with-http_addition_module 
--with-http_auth_request_module 
--with-http_dav_module 
--with-http_flv_module 
--with-http_gunzip_module 
--with-http_gzip_static_module 
--with-http_mp4_module 
--with-http_random_index_module 
--with-http_realip_module 
--with-http_secure_link_module 
--with-http_slice_module 
--with-http_ssl_module 
--with-http_stub_status_module 
--with-http_sub_module 
--with-http_v2_module 
--with-mail 
--with-mail_ssl_module 
--with-stream 
--with-stream_realip_module 
--with-stream_ssl_module 
--with-stream_ssl_preread_module 
--with-cc-opt='-g -O2 
-fdebug-prefix-map=/data/builder/debuild/nginx-1.17.9/debian/debuild-base/nginx-1.17.9=. 
-fstack-protector-strong -Wformat -Werror=format-security 
-Wp,-D_FORTIFY_SOURCE=2 -fPIC' 
--with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie'
```

#### Ubuntu 18.04 build info
```
nginx version: nginx/1.14.0 (Ubuntu)
built with OpenSSL 1.1.1  11 Sep 2018
TLS SNI support enabled
configure arguments: 
--with-cc-opt='-g -O2 -fdebug-prefix-map=/build/nginx-GkiujU/nginx-1.14.0=. 
-fstack-protector-strong -Wformat -Werror=format-security 
-fPIC -Wdate-time -D_FORTIFY_SOURCE=2' 
--with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now -fPIC' 
--prefix=/usr/share/nginx 
--conf-path=/etc/nginx/nginx.conf 
--http-log-path=/var/log/nginx/access.log 
--error-log-path=/var/log/nginx/error.log 
--lock-path=/var/lock/nginx.lock 
--pid-path=/run/nginx.pid 
--modules-path=/usr/lib/nginx/modules 
--http-client-body-temp-path=/var/lib/nginx/body 
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi 
--http-proxy-temp-path=/var/lib/nginx/proxy 
--http-scgi-temp-path=/var/lib/nginx/scgi 
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi 
--with-debug 
--with-pcre-jit 
--with-http_ssl_module 
--with-http_stub_status_module 
--with-http_realip_module 
--with-http_auth_request_module 
--with-http_v2_module 
--with-http_dav_module 
--with-http_slice_module 
--with-threads 
--with-http_addition_module 
--with-http_geoip_module=dynamic 
--with-http_gunzip_module 
--with-http_gzip_static_module 
--with-http_image_filter_module=dynamic 
--with-http_sub_module 
--with-http_xslt_module=dynamic 
--with-stream=dynamic 
--with-stream_ssl_module 
--with-mail=dynamic 
--with-mail_ssl_module
```
