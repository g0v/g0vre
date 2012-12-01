%.js: %.ls
	lsc -c $*

all :: extractor.js server.js

deploy: all
	jitsu deploy
