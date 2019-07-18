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
readonly GIT_ROOT_DIR=$( git rev-parse --show-toplevel )
readonly DOCKER_GIT_ROOT_DIR=/repo

declare DOCKER_HOSTNAME=docker-for-dev
readonly DOCKER_USER=devel

function help() {
    cat <<__EOF__
Usage: ${0} --docker-image IMAGE [OPTS] [-- [extra-docker-options]]

Otions:
    --docker-image       Docker image to run
    --ssh-dir DIR        Directory to mount as ~/.ssh
    --ports-web          Forward 3000:3000
    --ports-app          Forward expo-related ports
    --forward-ssh-agent  Make host's ssh-agent accessible inside docker
    --forward-x          Make host's X11 sockets accessible inside docker
                         Best used with Xephyr session
    --current-directory  Instead of git rood enter correspoding CWD
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
    local docker_image
    local forward_ssh_agent=false
    local forward_x=false
    local pass_host_aws_config=true
    local persistent_home=true
    local ports_app=false
    local ports_web=false
    local unconfined_debug=false
    local work_dir=${DOCKER_GIT_ROOT_DIR}

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
            --current-directory)
                work_dir=${DOCKER_GIT_ROOT_DIR}/$( git rev-parse --show-prefix )
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

    if [[ -n "${ssh_dir+x}" ]]; then
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

    if [[ "${persistent_home}" == true ]]; then
        extra_volume_params+=( --volume "$( realpath "${PROG_DIR}/persistent-home" ):/home/${DOCKER_USER}"  )
    fi

    if [[ "${unconfined_debug}" == true ]]; then
        # To be able to run strace and similar inside the container
        extra_other_params+=( --security-opt seccomp:unconfined )
    fi

    if [[ "${ports_web}" == true ]]; then
        extra_other_params+=( --publish 3000:3000 )
    fi

    if [[ "${ports_app}" == true ]]; then
        extra_other_params+=( --publish 19000:19000 --publish 19001:19001 --publish 19002:19002 )
    fi

    if [[ "${pass_host_aws_config}" == true ]]; then
        # To be able to run strace and similar inside the container
        extra_volume_params+=( --volume "${HOME}/.aws:/home/${DOCKER_USER}/.aws:ro"  )
    fi

    check_docker_image "${docker_image}"
    DOCKER_HOSTNAME=${docker_image//[^a-z0-9-]/-}

    exec docker run --rm -it \
    --hostname "${DOCKER_HOSTNAME}" \
    --env "LOCAL_USER_NAME=${DOCKER_USER}" \
    --env "LOCAL_USER_ID=${UID}" \
    --env "LOCAL_USER_GROUP=${GROUPS[0]}" \
    "${extra_env_params[@]}" \
    --volume "${GIT_ROOT_DIR}:${DOCKER_GIT_ROOT_DIR}" \
    "${extra_volume_params[@]}" \
    --volume "${PROG_DIR}/entrypoint.sh:/entrypoint.sh:ro" \
    --entrypoint /entrypoint.sh \
    --workdir "${work_dir}" \
    "${extra_other_params[@]}" \
    "${docker_image}" \
    "${@}"
}

main "${@}"
