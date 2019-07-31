.PHONY: test

build:
	stack build

test:
	stack test

test_watch:
	stack test --file-watch

stack2nix:
	stack2nix . > ./stack2nix.nix
