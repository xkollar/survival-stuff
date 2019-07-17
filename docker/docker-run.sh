#!/usr/bin/env bash

set -eu

## {{{ Tools #################################################################

function die() {
    echo "${1}" >&2
    exit 1
}

function fail() {
    echo "${1}" >&2
    return 1
}

# Sadly, neither readlink nor realpath are universaly present.
if ! type realpath >&/dev/null; then
    function realpath() {
        TARGET=${1:?Path to normalize}; shift
        (
            if cd "${TARGET}" >&/dev/null; then
                pwd -P
            elif cd "$( dirname "${TARGET}" )" >&/dev/null; then
                echo "$( pwd -P )/$( basename "${TARGET}" )"
            else
                fail "realpath: ${TARGET}: No such file or directory"
            fi
        )
    }
fi

## }}} Tools #################################################################

readonly PROG_DIR=$( dirname "$( realpath "${0}" )" )
readonly GIT_ROOT_DIR=$( cd "${PROG_DIR}" && git rev-parse --show-toplevel )

readonly DOCKER_HOSTNAME=docker-for-dev
readonly DOCKER_USER=docker-user

function help() {
    cat <<__EOF__
Usage: ${0} --docker-image IMAGE [OPTS] [-- [extra-docker-options]]

Otions:
    --docker_image       Docker image to run
    --ssh-dir DIR        Directory to mount as ~/.ssh
    --ports-web          Forward 3000:3000
    --ports-app          Forward expo-related ports
    --forward-ssh-agent  Make host's ssh-agent accessible inside docker
    --forward-x          Make host's X11 sockets accessible inside docker
                         Best used with Xephyr session
    --unconfined-debug   Disable security confinement
                         Allows strace and similar
    -h, --help           Display this help and exit

Note:
    extra-docker-options are passed after image parameter, so they will be
    passed to the entry point.
__EOF__
}

function check_docker_image {
    local -r image_name=${1?Docker image}; shift
    if ! docker inspect --type=image "${image_name}" >&/dev/null; then
        die "Unknown docker image: ${image_name}. Maybe try building using provided Dockerfile?"
    fi
}

function main() {
    local ssh_dir
    local forward_ssh_agent=false
    local forward_x=false
    local persistent_bash_history=true
    local unconfined_debug=false
    local bash_history_file=${GIT_ROOT_DIR}/docker/bash_history
    local docker_image
    local ports_web=false
    local ports_app=false

    local -a extra_volume_params=( )
    local -a extra_env_params=( )
    local -a extra_other_params=( )

    while [[ ${#} -gt 0 ]]; do
        local param=${1}; shift
        case "${param}" in
            --help|-h)
                help
                exit
                ;;
            --docker-image)
                docker_image=${1}; shift
                ;;
            --ssh-dir)
                ssh_dir=${1}; shift
                ;;
            --ssh-dir=*)
                ssh_dir=${param#*=}
                ;;
            --docker=*)
                docker_image=${param#*=}
                ;;
            --ports-web)
                ports_web=true
                ;;
            --ports-app)
                ports_app=true
                ;;
            --forward-ssh-agent)
                forward_ssh_agent=true
                ;;
            --forward-x)
                forward_x=true
                ;;
            --unconfined-debug)
                unconfined_debug=true
                ;;
            --)
                # Keep rest as positional arguments
                break
                ;;
            *)
                die "Unknown argument: ${param}"
                ;;
        esac
    done

    if [[ ! -z "${ssh_dir+x}" ]]; then
        extra_volume_params+=( --volume "$( realpath "${ssh_dir}" ):/home/${DOCKER_USER}/.ssh:ro" )
    fi
    if [[ "${forward_ssh_agent}" == true ]]; then
        extra_volume_params+=( --volume "${SSH_AUTH_SOCK:?SSH_AUTH_SOCK environment variable required}":/tmp/ssh-agent-sock )
        extra_env_params+=( --env "SSH_AUTH_SOCK=/tmp/ssh-agent-sock" )
    fi

    if [[ "${forward_x}" == true ]]; then
        extra_env_params+=( --env "DISPLAY=${DISPLAY}" )
        extra_volume_params+=( --volume /tmp/.X11-unix:/tmp/.X11-unix )
    fi

    if [[ "${persistent_bash_history}" == true ]]; then
        touch "${bash_history_file}"
        extra_volume_params+=( --volume "$( realpath "${bash_history_file}" ):/home/${DOCKER_USER}/.bash_history"  )
    fi

    if [[ "${unconfined_debug}" == true ]]; then
        # To be able to run strace and similar inside the container
        extra_other_params+=( --security-opt seccomp:unconfined )
    fi

    if [[ "${ports_web}" == true ]]; then
        extra_other_params+=( --publish 3000:3000 )
    fi

    if [[ "${unconfined_debug}" == true ]]; then
        # To be able to run strace and similar inside the container
        extra_other_params+=( --publish 19000:19000 --publish 19001:19001 --publish 19002:19002 )
    fi

    check_docker_image "${docker_image}"

    exec docker run --rm -it \
    --hostname "${DOCKER_HOSTNAME}" \
    --env "LOCAL_USER_NAME=${DOCKER_USER}" \
    --env "LOCAL_USER_ID=${UID}" \
    --env "LOCAL_USER_GROUP=${GROUPS[0]}" \
    "${extra_env_params[@]}" \
    "${extra_volume_params[@]}" \
    --volume "${PROG_DIR}:/entrypoint.sh" \
    --entrypoint /entrypoint.sh \
    "${extra_other_params[@]}" \
    "${docker_image}" \
    "${@}"
}

main "${@}"