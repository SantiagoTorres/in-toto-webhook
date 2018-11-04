NAME:=in-toto-webhook
DOCKER_REPOSITORY:=controlplane
DOCKER_IMAGE_NAME:=$(DOCKER_REPOSITORY)/$(NAME)
GITREPO:=github.com/santiagotorres/in-toto-webhook
GITCOMMIT:=$(shell git describe --dirty --always)
VERSION:=0.1-dev

.PHONY: build
build:
	docker build -t $(DOCKER_IMAGE_NAME):$(VERSION) -f Dockerfile .

.PHONY: push
push:
	docker push $(DOCKER_IMAGE_NAME):$(VERSION)

.PHONY: test
test:
	cd pkg/webhook ; go test -v -race ./...

.PHONY: certs
certs:
	cd deploy && ./gen-certs.sh

.PHONY: configmaps
configmaps:
	cd deploy && ./gen-configmaps.sh

.PHONY: deploy
deploy:
	-kubectl create namespace in-toto
	kubectl apply -f ./deploy/

.PHONY: delete
delete:
	kubectl delete namespace in-toto
	kubectl delete -f ./deploy/webhook-registration.yaml

travis_push:
	@docker tag $(DOCKER_IMAGE_NAME):$(VERSION) $(DOCKER_IMAGE_NAME):$(TRAVIS_BRANCH)-$(GITCOMMIT)
	@docker push $(DOCKER_IMAGE_NAME):$(TRAVIS_BRANCH)-$(GITCOMMIT)

travis_release:
	@docker tag $(DOCKER_IMAGE_NAME):$(VERSION) $(DOCKER_IMAGE_NAME):$(TRAVIS_TAG)
	@docker push $(DOCKER_IMAGE_NAME):$(TRAVIS_TAG)

exportcerts:
	grep 'key.pem' deploy/webhook-certs.yaml | awk '{print $$2}' | base64 -d > certs/key.pem
	grep 'cert.pem' deploy/webhook-certs.yaml | awk '{print $$2}' | base64 -d > certs/cert.pem

testserialize:
	curl -k https://localhost:8080/links/someorganization/someimage/package.2f89b927.link \
		-d test/package.2f89b927.link

binary:
	go build -a -o in-toto ./cmd/in-toto

