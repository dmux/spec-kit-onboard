MD_FILES := $(shell find . -name '*.md' -not -path './.git/*' -not -name 'spec-kit-onboard.md')

lint:
	markdownlint-cli2 $(MD_FILES)

.PHONY: lint
