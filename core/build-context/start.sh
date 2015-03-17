#!/bin/bash

echo "============================================="

export DATABASE_URL=postgresql://${DB_ENV_PGSQL_USER}:${DB_ENV_PGSQL_PASS}@db:${DB_ENV_PGSQL_PORT}
export REDIS_URL=redis://redis:$(env | grep REDIS_PORT_[0-9]*_TCP_PORT | cut -d= -f2)/0
export RAILS_ENV=production

cd asciinema.org/
case "$1" in
	setup)
		echo Setting up database ...
		bundle exec rake db:setup
		;;
	sidekiq)
		echo Starting sidekiq ...
		bundle exec sidekiq
		;;
	*)
		echo Starting web server ...
		bundle exec rails server
		;;

esac

echo "============================================="
