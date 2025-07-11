# SPDX-FileCopyrightText: 2023-2025 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

.DEFAULT_GOAL := help

APP_ID := talk_bot_ai
APP_NAME := AssistantTalkBot
APP_VERSION := $$(xmlstarlet sel -t -v "//version" appinfo/info.xml)
JSON_INFO := "{\"id\":\"$(APP_ID)\",\"name\":\"$(APP_NAME)\",\"daemon_config_name\":\"manual_install\",\"version\":\"$(APP_VERSION)\",\"secret\":\"12345\",\"port\":10034}"

.PHONY: help
help:
	@echo "  Welcome to Nextcloud $(APP_NAME) $(APP_VERSION)!"
	@echo " "
	@echo "  Please use \`make <target>\` where <target> is one of"
	@echo " "
	@echo "  build-push        builds CPU images and uploads them to ghcr.io"
	@echo " "
	@echo "  > Next commands are only for the dev environment with nextcloud-docker-dev!"
	@echo "  > They must be run from the host you are developing on, not in a Nextcloud container!"
	@echo " "
	@echo "  run               installs $(APP_NAME) for Nextcloud Latest"
	@echo "  run30             installs $(APP_NAME) for Nextcloud 30"
	@echo "  run31             installs $(APP_NAME) for Nextcloud 31"
	@echo " "
	@echo "  > Commands for manual registration of ExApp ($(APP_NAME) should be running!):"
	@echo " "
	@echo "  register          performs registration of running $(APP_NAME) into the 'manual_install' deploy daemon."
	@echo "  register30        performs registration of running $(APP_NAME) into the 'manual_install' deploy daemon."
	@echo "  register31        performs registration of running $(APP_NAME) into the 'manual_install' deploy daemon."
	@echo " "


.PHONY: build-push
build-push:
	docker login ghcr.io
	docker buildx create --name $(APP_ID) --driver docker-container --platform linux/amd64,linux/arm64 --use || true
	docker buildx build --push --platform linux/arm64,linux/amd64 --tag ghcr.io/nextcloud/$(APP_ID):$(APP_VERSION) --tag ghcr.io/nextcloud/$(APP_ID):latest .

.PHONY: run
run:
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:unregister $(APP_ID) --silent --force || true
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:register $(APP_ID) \
		--info-xml https://raw.githubusercontent.com/nextcloud/$(APP_ID)/main/appinfo/info.xml

.PHONY: run30
run30:
	docker exec master-stable30-1 sudo -u www-data php occ app_api:app:unregister $(APP_ID) --silent --force || true
	docker exec master-stable30-1 sudo -u www-data php occ app_api:app:register $(APP_ID) \
		--info-xml https://raw.githubusercontent.com/nextcloud/$(APP_ID)/main/appinfo/info.xml

.PHONY: run31
run31:
	docker exec master-stable31-1 sudo -u www-data php occ app_api:app:unregister $(APP_ID) --silent --force || true
	docker exec master-stable31-1 sudo -u www-data php occ app_api:app:register $(APP_ID) \
		--info-xml https://raw.githubusercontent.com/nextcloud/$(APP_ID)/main/appinfo/info.xml

.PHONY: register
register:
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:unregister $(APP_ID) --silent --force || true
	docker exec master-nextcloud-1 sudo -u www-data php occ app_api:app:register $(APP_ID) manual_install --json-info $(JSON_INFO) --wait-finish

.PHONY: register30
register30:
	docker exec master-stable30-1 sudo -u www-data php occ app_api:app:unregister $(APP_ID) --silent --force || true
	docker exec master-stable30-1 sudo -u www-data php occ app_api:app:register $(APP_ID) manual_install --json-info $(JSON_INFO) --wait-finish

.PHONY: register31
register31:
	docker exec master-stable31-1 sudo -u www-data php occ app_api:app:unregister $(APP_ID) --silent --force || true
	docker exec master-stable31-1 sudo -u www-data php occ app_api:app:register $(APP_ID) manual_install --json-info $(JSON_INFO) --wait-finish
