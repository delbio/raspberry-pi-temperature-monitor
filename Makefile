install:
	git submodule update --init
	git branch
	git checkout master

update:
	git pull
	git submodule sync
	git submodule update --init
