## Nginx common useful configuration

Nginx configs. Not the most powerful, productive or the best one. Just useful configs, which I would like to see in default nginx packages out of the box 😆
Bonus: fail2ban, filebeat and docker-compose configs for nginx :)

Warning: I'm living in Belarus - country between EU and Russia. [And today we are fighting for our freedom against 'the last dictator of the Europe'](https://www.euronews.com/2020/06/25/belarus-is-no-longer-scared-of-lukashenko-europe-s-last-dictator-will-fall-view).
So I can't guarantee that I'll be able to maintain this repo scrupulously this summer. Sorry, guys

**Motivation**: I have been using nginx for last 4 years at least, and I configured it really for hundreds setups of 30+ companies and startups: sites, apps, websockets, proxies, load balancing, from few up to 1k rps, etc... And I'm a little bit disappointed by [the official nginx wiki](https://www.nginx.com/resources/wiki/).
The last drop was this [blog post in the official blog](https://www.nginx.com/blog/help-the-world-by-healing-your-nginx-configuration/):
this post doesn't provide a complete solution, half of these tips can be included into nginx configs or snippets by default,
and some of the other tips, such as disabling access logging, in my opinion are the bad practice 😆

At the same time there are a lot good documentation and best practices:
[nginx docs](https://nginx.org/en/docs/),
[digitalocean config generator](https://www.digitalocean.com/community/tools/nginx),
[mozilla ssl best practices](https://ssl-config.mozilla.org/#server=nginx&version=1.17.7&config=intermediate&openssl=1.1.1d&guideline=5.4),
etc... And here I'm trying to put together all good patterns and knowledges so anyone will be able to copy this configs and get good nginx setup out of the box :)

There is also interesting [openbridge nginx](https://github.com/openbridge/nginx) docker image,
but I haven't checked it properly yet, their configs require addition nginx modules and setup
and it can't be just copied to usual nginx. However, you can use it with docker.
Also I don't agree with nginx microcache for every site, see known traps.

Time track:
- [Filipp Frizzy](https://github.com/Friz-zy/) 35.84h

### Support

You can support this or any other of my projects
* by sending your PRs with improving my configs or english texts 😂
* by sending me donations:
  - [donationalerts.com/r/filipp_frizzy](https://www.donationalerts.com/r/filipp_frizzy)
  - ETH 0xCD9fC1719b9E174E911f343CA2B391060F931ff7
  - BTC bc1q8fhsj24f5ncv3995zk9v3jhwwmscecc6w0tdw3

### Configs

#### Main configs
Almost all sections moved from main `nginx.conf` into `conf.d` directory:

* `basic.conf`  
Basic settings, mime types, charset, index, timeouts, open file cache, etc...
* `cache.conf`  
Fastcgi, Proxy and Uwsgi cache setup, see known traps before using ;)
* `gzip.conf`  
Gzip and gzip static
* `log_format.conf`  
Extended log formats
* `real_ip.conf`  
Allow X-Forwarded-For header from local networks and [cloudflare](https://www.cloudflare.com/)
* `request_id.conf`  
Add X-Request-ID header into each request for tracing and debugging
* `security.conf`  
Security settings and headers
* `ssl.conf`  
SSL best practice from [mozilla](https://ssl-config.mozilla.org/#server=nginx&version=1.17.7&config=intermediate&openssl=1.1.1d&guideline=5.4)

#### Snippets
Templates and includes. You can also use [config generator](https://www.digitalocean.com/community/tools/nginx) from digitalocean :)

* `corps.conf.j2`  
Template of corps politic for multiple subdomains setup
* `default.conf`  
Example of default config with nginx_status, let's encrypt check and redirect to https
* `fastcgi.conf`  
Include for php locations: fastcgi parameters, timeouts and cache example
* `headers.conf`  
Include with all headers, see known traps
* `protected_locations.conf`  
Include with protected locations with 'deny all'
* `proxy.conf`  
Include for proxy locations: proxy headers, parameters, timeouts and cache example
* `referer.conf.j2`  
Template of referer protection for cases when you concurents use your fail2ban protection against you, see known traps
* `site.conf.j2`  
Template of common site configuration
* `static_location.conf`  
Include with location for static files

#### Docker-compose
`docker-compose.yml` example for nginx

#### Fail2ban
You can use fail2ban for banning some bots even behind load balancer.
`nginx-deny` action will add `deny <ip>;` into `/etc/nginx/conf.d/banned.conf` and reload nginx.

Warning: your evil competitors can use your protection like fail2ban against you, check known traps ;)

Files for copying:
```
fail2ban/jail.local => /etc/fail2ban/jail.local
fail2ban/action-nginx-deny.conf => /etc/fail2ban/action.d/nginx-deny.conf
fail2ban/filter-magento.conf => /etc/fail2ban/filter.d/nginx-magento.conf
fail2ban/filter-wordpress.conf => /etc/fail2ban/filter.d/nginx-wordpress.conf
fail2ban/filter-nginx-noscript.conf => /etc/fail2ban/filter.d/nginx-noscript.conf
```

#### Filebeat
Filebeat by default can't parse extended nginx access log formats, so you should override ingest json:
Copy `filebeat/nginx_access_ingest.json` to `/usr/share/filebeat/module/nginx/access/ingest/default.json`

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

In this configuration I suggest caches only as an additional tool for caching common non 200 status responses:
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

#### Fail2ban and any other protection can be used against you

Not only that incorrectly configured protection will block valid users,
even right configured protection like fail2ban, especially with `botsearch-common` filter,
can be used for attack to you. For example, you competitors can add to their sites something like
```
<img src="https://{{ your site }}/admin/1.jpg">
<img src="https://{{ your site }}/phpmyadmin/1.jpg">
<img src="https://{{ your site }}/roundcube/1.jpg">
```

Then valid user after visit to the their site will be automatically blocked on your site 😆
You can fight with this practice using `http_referer`, see `snippets/referer.conf.j2` template ;)
Warning: I have not tested this code yet

#### Errors like ` failed (24: Too many open files)` or `worker_connections exceed open file resource limit`

Problem with limit of open files (`ulimit -n`)

You can change it
* systemd  
Add into `/etc/systemd/system/nginx.d/override.conf`
```
[Service]
LimitNOFILE=100000
```
* old init system  
Change `/etc/default/nginx`
```
ULIMIT="-n 100000"
```
* docker-compose
```
ulimits:
  nproc: 65535
  nofile:
    soft: 100000
    hard: 100000
```

Maybe you should also change `/etc/security/limits.conf`
```
nginx           hard    nofile          100000
nginx           soft    nofile          100000
www-data        hard    nofile          100000
www-data        soft    nofile          100000
```
and `/etc/sysctl.conf`
```
fs.file-max = 394257
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
