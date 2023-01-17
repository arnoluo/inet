.PHONY: conf log src storage

build:
	[ -f ./.env ] || (cp .env.example .env && echo "autocreating .env")
	[ -f ./conf/alertmanager/alertmanager.yml ] || (cp ./conf/alertmanager/alertmanager.yml.tpl ./conf/alertmanager/alertmanager.yml && echo "autocreating ./conf/alertmanager/alertmanager.yml")
	[ -f ./docker-compose.yml ] || (cp ./docker-compose-dev.yml ./docker-compose.yml && echo "autocreating ./docker-compose.yml")
	make ngcfg port=80 name=html path=html
	docker compose build

dns:
	cp -f conf/dnsmasq/inet.conf /usr/local/etc/dnsmasq.d/inet.conf
	brew services restart dnsmasq

up: down
	docker compose up --remove-orphans

upd: down
	docker compose up -d --remove-orphans

npa:
	docker compose exec -it npa /bin/sh

down:
	docker compose down

clean: down
	rm -rf log/*/*.log*

logs:
	docker compose logs

test:
	curl inet
	curl prom.inet

# make ngcfg port=80 name=html path=html
# make ngcfg port=81 name=test path=test
ngcfg:
	export CONTAINER_PORT=$(port) SERVER_NAME=$(name) RELATIVE_PATH=$(path) REAL_DOLLAR=$$ && cat ./conf/nginx/conf.d/conf.tpl | envsubst > ./conf/nginx/conf.d/${name}_${port}.conf