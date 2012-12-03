%.js: %.ls
	lsc -c $*

all :: extractor.js aec.js server.js

deploy: all
	jitsu deploy
