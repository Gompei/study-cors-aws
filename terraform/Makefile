-include .env

MAKEFILE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PARENT_DIR:=$(shell dirname ${MAKEFILE_DIR})

API_DOMAIN="<API Gateway Domain>"
S3_BUCKET_NAME="example-study-cors-aws"

.PHONY: help
help: ## 各makeコマンドの説明を表示します
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

frontend-build: ## frontendソースをビルドします
	npm install --prefix ${PARENT_DIR}/frontend
	npm run generate --prefix ${PARENT_DIR}/frontend

backend-build: ## backendソースをビルドします
	GOOS=linux GOARCH=amd64 go build -o handler ../backend
	zip lambda.zip handler

.PHONY: apply
apply: frontend-build backend-build ## tf ファイルに記載された情報を元にリソースを作成します
	terraform apply -auto-approve
	aws s3 sync ${PARENT_DIR}/frontend/dist s3://${S3_BUCKET_NAME} --delete

.PHONY: destroy
destroy: ## tf ファイルに記載された情報を元にリソースを削除します
	aws s3 rm s3://${S3_BUCKET_NAME} --recursive
	terraform destroy -auto-approve

api-test:
	curl https://${API_DOMAIN}/api/test