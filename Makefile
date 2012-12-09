%.js: %.ls
	lsc -c $*

all :: server.js extractor.js aec.js taipower.js cwbtw.js

deploy: all
	jitsu deploy
