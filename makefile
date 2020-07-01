clean:
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
	rm -rf dist
	rm dist.zip

verify:
	pytest	

package:
	cp -r src/ dist/
	pip install -r requirements-prod.txt -t dist
	(cd dist && zip -r ../dist.zip .)

all:
	make clean verify package	