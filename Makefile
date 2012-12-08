%.js: %.ls
	lsc -c $*

all :: server.js extractor.js aec.js taipower.js

deploy: all
	jitsu deploy
