PROJECT_NAME := test-webpack-init

install:
	$(MAKE) npm-install

build:
	npm run build
	-git add dist/
