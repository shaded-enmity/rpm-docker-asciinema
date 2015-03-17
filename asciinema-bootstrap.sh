#!/bin/bash

_vardir=/var/lib/asciinema-docker

if [[ -f "${_vardir}/container-names.env" ]]; then
        source ${_vardir}/container-names.env
else
        echo "File 'container-names.env' not found; bailing ..."
        exit 1
fi

notify-attach() {
  systemd-notify --ready --pid $$
  docker attach $1
}

first-time-setup() {
  if [[ ! -f "${_vardir}/.setup" ]]; then
    sleep 5 

    docker run --link ${ASCIINEMA_PSQL}:db \
      --name ${ASCIINEMA_CORE} ${ASCIINEMA_CORE} \
      /start.sh setup >/dev/null 2>&1

    [[ $? = 0 ]] && touch ${_vardir}/.setup
    docker rm -f ${ASCIINEMA_CORE} >/dev/null
  fi
}

_name_list="${ASCIINEMA_CORE} ${ASCIINEMA_SDKQ} ${ASCIINEMA_PSQL} ${ASCIINEMA_REDS}"

case "$1" in
	core)

	  first-time-setup

	  core_cid=$(docker run \
                      --link ${ASCIINEMA_PSQL}:db \
                      --link ${ASCIINEMA_REDS}:redis \
                      -v ${_vardir}/uploads/:/asciinema.org/public/uploads \
                      -p ${_port:-3000}:3000 \
                      -d --name ${ASCIINEMA_CORE} ${ASCIINEMA_CORE})

          notify-attach ${core_cid}
	;;

	sidekiq)

	  sdkq_cid=$(docker run \
                      --link ${ASCIINEMA_PSQL}:db \
                      --link ${ASCIINEMA_REDS}:redis \
                      --volumes-from ${ASCIINEMA_CORE} \
                      -d --name ${ASCIINEMA_SDKQ} ${ASCIINEMA_CORE} \
                      /start.sh sidekiq)

          notify-attach ${sdkq_cid}
	;;

	redis)

	  reds_cid=$(docker run --env-file=${_vardir}/redis-env.list \
          	      -v ${_vardir}/redis:/var/lib/redis -d \
                      --name ${ASCIINEMA_REDS} ${ASCIINEMA_REDS})

          notify-attach ${reds_cid}
	;;

	postgresql)

	  psql_cid=$(docker run --env-file=${_vardir}/postgres-env.list \
          	      -v ${_vardir}/pgsql:/var/lib/postgresql -d \
                      --name ${ASCIINEMA_PSQL} ${ASCIINEMA_PSQL})

          notify-attach ${psql_cid}
	;;

	wait-core)

	  systemd-notify --ready --pid $$ 
	  docker wait ${ASCIINEMA_CORE}
	;;

	teardown)

	  docker kill ${_name_list} >/dev/null 2>&1
	  docker rm -f ${_name_list} >/dev/null 2>&1
	;;

	*)
		echo " $0 SERVICE"
		echo " Available services:"
		echo "  core"
		echo "  sidekiq"
		echo "  redis"
		echo "  postgresql"
		echo "  wait-core"
		echo "  teardown"
	;;
esac
