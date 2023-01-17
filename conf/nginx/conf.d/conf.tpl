server {
    listen       ${CONTAINER_PORT};
    server_name  ${SERVER_NAME};
    root   /var/www/${RELATIVE_PATH};
    index  index.html index.htm index.php;
    charset utf-8;
    access_log  /var/log/npa/${SERVER_NAME}.access.log  main;
    error_log  /var/log/npa/${SERVER_NAME}.error.log warn;

    error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # location / {
    #     rewrite ^ https://$host$request_uri? permanent;
    # }

    # location ^~ /.well-known {
    #     allow all;
    #     root  /var/lib/letsencrypt;
    # }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php$ {
        fastcgi_pass   unix:/var/run/php-fpm.sock;
        fastcgi_index  index.php;
        include        fastcgi_params;
        fastcgi_param  SCRIPT_FILENAME  ${REAL_DOLLAR}document_root${REAL_DOLLAR}fastcgi_script_name;
    }

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
