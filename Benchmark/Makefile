pods-install:
	bundle exec pod install || bundle exec pod install --repo-update

gems-install:
	bundle check || bundle install --path vendor/bundle --clean --jobs=4
