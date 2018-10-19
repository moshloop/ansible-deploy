NAME := "ansible-deploy"
VERSION := $(shell git tag --points-at HEAD )

ifdef VERSION
else
  VERSION := $(shell git describe --abbrev=0 --tags)-debug
endif


.PHONY: package
package:
	$(shell rm *.rpm || true)
	$(shell rm *.deb || true)
	docker run --rm -it -v $(CURDIR):$(CURDIR) -w $(CURDIR) alanfranz/fpm-within-docker:ubuntu-xenial fpm  -s dir -t deb -n $(NAME) -v $(VERSION) -x "*.DS_Store"/ -x ".git" ./=/etc/ansible/roles/deploy
	mv *.deb $(NAME).deb
	docker run --rm -it -v $(CURDIR):$(CURDIR) -w $(CURDIR) alanfranz/fpm-within-docker:centos-7 fpm  -s dir -t rpm -n $(NAME) -v $(VERSION) -x "*.DS_Store" -x ".git" ./=/etc/ansible/roles/deploy
	mv *.rpm $(NAME).rpm