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
: ${CURL_ARGS="--retry 5 --retry-delay 1"}

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

_exit() {
	_echo "$@"
	exit 1
}

_kill() {
	kill "$@" >/dev/null 2>&1
}

_curl() {
	local url=$1
	local out=$2
	local status

	${CURL} -s ${CURL_ARGS} ${url} -o ${out}

	(( status = $? ))
	(( status > 0 )) \
		&& _echo "curl ${url} failed. Return status: ${status}."

	return ${status}
}

curl_proxy() {
	local url=$1
	local out=$2

	_echo "${out} get"

	if [ ! -f ${out} ]
	then
		_curl ${url} ${out} \
			|| _exit "${out} not found. Exiting."

		return 1
	fi

	_curl ${url} ${out}_

	if (( $? > 0 ))
	then
		_echo "Using old ${out}"
		return 0
	fi

	cmp -s ${out} ${out}_

	if (( $? > 0 ))
	then
		mv ${out}_ ${out}
		_echo "${out} updated"
		return 1
	fi

	rm ${out}_
	_echo "${out} has not changed"
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

mtpxy_bg() {
	${MTPROXY} \
		--user=${USER} \
		--port=${PORT} \
		--http-ports=${HTTP_PORTS} \
		--mtproto-secret=${SECRET} \
		--aes-pwd=${PROXY_SECRET} \
		${ARGS} \
		${PROXY_CONFIG} \
		>${LOG} 2>&1 &

	mtpxy_pid=$!
}

sleep_bg() {
	local s1 s2 ts

	(( s1 = $(date +%s) ))
	(( s2 = $(date +%s -d "${DATESTR}") ))
	(( ts = ${s2} - ${s1} ))

	sleep ${ts} &

	sleep_pid=$!
}

loop() {
	# Validate ${DATESTR}
	date + -d "${DATESTR}" >/dev/null 2>&1 \
		|| _exit "Wrong date format: ${DATESTR}. Exiting."

	[[ ${SECRET} ]] \
		|| _exit "MTProto secret is not set. Exiting."

	curl_all

	mtpxy_bg

	_echo "MTProxy started"

	while true
	do
		sleep_bg

		_echo "Sleep until "$(_date -d "${DATESTR}")"."

		wait -n \
			|| _exit "MTProxy return bad status: $?. Exiting."

		_kill ${sleep_pid} \
			&& _echo "Warning: MTProxy was terminated before timer is out"

		curl_all && continue

		_kill ${mtpxy_pid} \
			|| _echo "Warning: MTProxy was already stopped after curl_all"

		wait \
			|| _exit "MTProxy return bad status after curl_all: $?. Exiting."

		mtpxy_bg

		_echo "MTProxy restarted"
	done
}

cleanup() {
	_kill ${mtpxy_pid} ${sleep_pid}

	if (( $1 == 0 ))
	then
		wait
		_echo "MTProxy status: $?. Exiting."
	fi
}

mtpxy_pid=$$
sleep_pid=$$

trap "exit 0" INT TERM
trap "cleanup \$?" EXIT

case $1 in
curl)
	curl_all
	;;
loop)
	loop
	;;
mtproxy)
	mtpxy_bg
	wait
	;;
sleep)
	sleep_bg
	wait
	;;
*)
	_exit "Wrong arguments. Exiting."
	;;
esac

