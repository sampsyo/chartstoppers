NODE_DEPS := bower@~1.3.9 less@~1.7.4
BOWER_DEPS := bootstrap\#~3.2.0 octicons\#~2.1.2
OCTICONS_EXT := eot svg ttf woff
STATIC := media/main.css $(OCTICONS_EXT:%=media/octicons.%)
HTML := _site/index.html
DEST := dh:domains/chartstoppers.radbox.org

.PHONY: setup clean clean_site build serve deploy

build: $(STATIC) $(HTML)

# Somewhat dumb way to invoke setup on first run (but not thereafter) or on
# manual invocation.
BOWER_STUFF := bower_components/bootstrap/bower.json
BOWER := node_modules/bower/bin/bower
$(BOWER_STUFF): $(BOWER)
	./node_modules/bower/bin/bower install $(BOWER_DEPS)
	touch $@
$(BOWER):
	npm install $(NODE_DEPS)
setup: $(BOWER_STUFF)

# Build static components.
media/main.css: _src/main.less $(BOWER_STUFF)
	./node_modules/less/bin/lessc $(LESSARGS) $< $@
media/octicons.%: $(BOWER_STUFF)
	cp bower_components/octicons/octicons/octicons.$* $@

$(HTML): index.html $(STATIC)
	jekyll build $(JEKYLLARGS)

clean:
	rm -rf node_modules bower_components media _site
clean_site:
	rm -rf media _site

serve:
	jekyll serve -w $(JEKYLLARGS)

S3BUCKET := chartstoppers.com
S3SYNCARGS := --size-only
ifeq ($(wildcard audio),)
	# Do not delete the audio directory on remote.
	S3SYNCARGS += --exclude audio
endif
deploy: build
	aws s3 sync $(S3SYNCARGS) _site/ s3://$(S3BUCKET)

LOG_DIR := logs
LOG_BUCKET := chartstoppers-logs
GOACCESS_ARGS := \
	--log-format '%^ %^ [%d:%^] %h %^ %^ %^ %^ "%^ %r %^" %s %^ %b %^ %^ \
	%^ "%^" "%u" %^' \
	--date-format '%d/%b/%Y' \
	--time-format '%f' \
	--agent-list
.PHONY: getlogs
getlogs:
	aws s3 sync s3://$(LOG_BUCKET) $(LOG_DIR)
report.html: $(LOG_DIR)
	find $< -type f | xargs cat | goaccess $(GOACCESS_ARGS) > $@
