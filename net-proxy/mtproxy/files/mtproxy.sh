#!/bin/bash

: ${CONFIG="mtproxy.conf"}

source ${CONFIG}

: ${USER="nobody"}
: ${PORT="8888"}
: ${HTTP_PORTS="5443"}
: ${LOG="mtproto-proxy.log"}
: ${ARGS="-M 1"}

: ${DATESTR="1 day 03:00:00"}

: ${CURL="/usr/bin/curl"}
: ${CURL_ARGS="--max-filesize 1m"}
: ${CURL_DELAY="5"}

: ${MTPROXY="/usr/bin/mtproto-proxy"}

: ${PROXY_CONFIG_URL="https://core.telegram.org/getProxyConfig"}
: ${PROXY_SECRET_URL="https://core.telegram.org/getProxySecret"}

: ${PROXY_CONFIG="proxy-multi.conf"}
: ${PROXY_SECRET="proxy-secret"}

_date() {
	date +'%F %T' "$@"
}

_echo() {
	echo "["$(_date)"]" "$@"
}

_kill() {
	kill "$@" >/dev/null 2>&1
}

check_datestr() {
	# Validate ${DATESTR}
	date + -d "${DATESTR}" >/dev/null 2>&1

	if (( $? > 0 ))
	then
		_echo "Wrong date format: ${DATESTR}. Exiting."
		exit 1
	fi
}

check_secret() {
	if [[ ! ${SECRET} ]]
	then
		_echo "MTProto secret is not set. Exiting."
		exit 1
	fi
}

curl_bg() {
	local url=$1
	local out=$2

	${CURL} -s ${CURL_ARGS} ${url} -o ${out} &
}

mtpxy_bg() {
	${MTPROXY} \
		--user=${USER} \
		--port=${PORT} \
		--http-ports=${HTTP_PORTS} \
		--mtproto-secret=${SECRET} \
		--aes-pwd=${PROXY_SECRET} \
		${ARGS} ${PROXY_CONFIG} \
		>${LOG} 2>&1 &
}

sleep_bg() {
	local s1 s2 ts

	(( s1 = $(date +%s) ))
	(( s2 = $(date +%s -d "${DATESTR}") ))
	(( ts = ${s2} - ${s1} ))

	sleep ${ts} &
}

curl_proxy() {
	local url=$1
	local out=$2
	local status

	_echo "Download ${out}"

	while true
	do
		curl_bg ${url} ${out}_
		child_pid=$!

		wait ${child_pid} && break

		sleep ${CURL_DELAY} &
		child_pid=$!

		wait ${child_pid}
	done

	cmp -s ${out} ${out}_
	status=$?

	if (( status > 0 ))
	then
		mv ${out}_ ${out}
		_echo "${out} updated"
	else
		rm ${out}_
		_echo "${out} has not changed"
	fi

	return ${status}
}

curl_all() {
	local status

	curl_proxy \
		${PROXY_CONFIG_URL} \
		${PROXY_CONFIG}

	(( status = $? ))

	curl_proxy \
		${PROXY_SECRET_URL} \
		${PROXY_SECRET}

	(( status |= $? ))

	return ${status}
}

watch_cleanup() {
	_kill ${mtpxy_pid}
	wait ${mtpxy_pid}
	exit $?
}

watch() {
	local status

	trap "watch_cleanup" INT TERM

	mtpxy_bg
	mtpxy_pid=$!

	wait ${mtpxy_pid}
	status=$?

	_kill $$

	exit ${status}
}

cleanup() {
	local child_status
	local watch_status

	_kill ${child_pid} ${watch_pid}

	wait ${child_pid}
	child_status=$?

	wait ${watch_pid}
	watch_status=$?

	_echo \
		"MTProxy status: ${watch_status}." \
		"Subtask status: ${child_status}." \
		"Exiting."

	exit $(( watch_status > 0 ))
}

run() {
	child_pid=$$
	mtpxy_pid=$$
	watch_pid=$$

	trap "cleanup" INT TERM

	local -i rtime=0

	curl_all

	watch &
	watch_pid=$!

	_echo "MTProxy started"

	while true
	do
		sleep_bg
		child_pid=$!

		_echo "Sleep until "$(_date -d "${DATESTR}")

		wait ${child_pid}

		curl_all && continue

		_kill ${watch_pid}

		wait ${watch_pid} \
			|| _echo "Warning: MTProxy status: $?"

		watch &
		watch_pid=$!

		_echo "MTProxy restarted "$(( rtime += 1 ))" time"
	done
}

case $1 in
curl)
	curl_all
	;;
mtproxy)
	check_secret
	mtpxy_bg
	wait $!
	;;
sleep)
	check_datestr
	sleep_bg
	wait $!
	;;
run)
	check_datestr
	check_secret
	run
	;;
*)
	_echo "Wrong arguments. Exiting."
	exit 1
	;;
esac
