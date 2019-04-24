#!/bin/bash

set -euo pipefail
set -x

function download() {
    local url="$1"; shift
    local dest="$1"; shift
    local scheme="${url%%:*}"

    case "${scheme}" in
        s3)
            aws s3 cp "${url}" "${dest}"
            ;;
        http?)
            curl -o "${dest}" "${url}"
            ;;
        *)
            echo "Unsupported URL scheme ${scheme}"
            exit 1
    esac
}

function extract() {
    local filename="$1"; shift
    local outdir="$1"; shift

    case "${filename}" in
        *.zip)
            unzip "${tempfile}" -d "${outdir}"
            ;;
        *.tar.gz)
            tar -C "${outdir}" -xvf "${tempfile}" --gzip
            ;;
        *.tar.bz)
            tar -C "${outdir}" -xvf "${tempfile}" --bzip2
            ;;
        *.tar.xz)
            tar -C "${outdir}" -xvf "${tempfile}" --xz
            ;;
        *)
            echo "Unknown file extension; unsure how to extract this file"
            exit 1
    esac
}

function verify_integrity() {
    local tempfile="$1"; shift
    local sha1="$1"; shift
    [[ -z ${sha1} ]] && return 0

    sha1sum "${tempfile}" | grep -E "^${sha1}  ${tempfile}$"
}

function main() {
    echo "Fetching ${SOURCE_URL}; will extract to ${OUTPUT_PATH}"

    local basename="${SOURCE_URL##*/}"
    local tempfile="/tmp/${basename}"

    download "${SOURCE_URL}" "${tempfile}"

    verify_integrity "${tempfile}" "${SOURCE_SHA1:-}"

    extract "${tempfile}" "${OUTPUT_PATH}"
}

main
