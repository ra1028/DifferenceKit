gems-install:
	bundle config path vendor/bundle
	bundle install --jobs 4 --retry 3

docs-gen:
	bundle exec jazzy --config .jazzy.yaml

lib-lint:
	bundle exec pod lib lint

pod-release:
	bundle exec pod trunk push DifferenceKit.podspec

test-linux:
	docker run -v `pwd`:`pwd` -w `pwd` --rm swift:latest swift test

mod:
	swift run -c release --package-path ./Packages swift-mod

mod-check:
	swift run -c release --package-path ./Packages swift-mod --check

generate-linuxmain:
	swift test --generate-linuxmain
