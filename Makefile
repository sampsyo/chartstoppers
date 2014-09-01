NODE_DEPS := bower@~1.3.9 less@~1.7.4
BOWER_DEPS := bootstrap\#~3.2.0 jquery\#~2.1.1 mediaelement\#~2.15.1
STATIC := media/main.css media/jquery.js media/mediaelement.js
HTML := _site/index.html

.PHONY: setup clean build serve

build: $(STATIC) $(HTML)

# Somewhat dumb way to invoke setup on first run (but not thereafter) or on
# manual invocation.
BOWER_STUFF := bower_components/bootstrap/bower.json
$(BOWER_STUFF):
	npm install $(NODE_DEPS)
	./node_modules/bower/bin/bower install $(BOWER_DEPS)
setup: $(BOWER_STUFF)

# Build static components.
media/main.css: _src/main.less $(BOWER_STUFF)
	./node_modules/less/bin/lessc $(LESSARGS) $< $@
media/jquery.js: bower_components/jquery/dist/jquery.min.js
	cp $< $@
media/mediaelement.js: bower_components/mediaelement/build/mediaelement-and-player.min.js
	cp $< $@

$(HTML): index.html $(STATIC)
	jekyll build $(JEKYLLARGS)

clean:
	rm -rf node_modules bower_components $(STATIC) _site

serve:
	jekyll serve -w $(JEKYLLARGS)
