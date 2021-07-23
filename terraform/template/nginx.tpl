upstream backend {
%{ for ip in public_ip ~}
    server ${ip}:443;
%{ endfor ~}
}
server {
    server_name isphone.ga www.isphone.ga;
    access_log /var/log/isphone_access.log;
    error_log /var/log/isphone_error.log;

    location / {
      proxy_set_header        Host $host;
      proxy_set_header        X-Real-IP $remote_addr;
      proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto $scheme;
      proxy_pass          https://backend;
      proxy_read_timeout  90;
    }
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/nginx/conf.d/ssl/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/nginx/conf.d/ssl/privkey.pem; # managed by Certbot
    include /etc/nginx/conf.d/ssl/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/nginx/conf.d/ssl/ssl-dhparams.pem; # managed by Certbot
}
server {
    if ($host = www.isphone.ga) {
        return 301 https://$host$request_uri;
    } # managed by Certbot
    if ($host = isphone.ga) {
        return 301 https://$host$request_uri;
    } # managed by Certbot
    listen 80;
    server_name isphone.ga www.isphone.ga;
    return 404; # managed by Certbot
}