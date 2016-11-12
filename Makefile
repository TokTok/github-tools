export GITHUB_TOKEN := $(shell cat ~/.github-token)

run: dist/build/pull-status/pull-status
	$<

changelog: dist/build/changelog/changelog
	$<

dist/build/changelog/changelog: dist/build/pull-status/pull-status
dist/build/pull-status/pull-status: dist/setup-config $(shell find src -type f)
	cabal build

dist/setup-config: pull-status.cabal
	cabal configure
