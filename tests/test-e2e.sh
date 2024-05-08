#!/usr/bin/env bash

function failed() {
    echo "Test failed"
    teardown
    exit 1
}

function teardown() {
    echo "Tearing down"
    make kind-down
}

echo "Starting test"

make kind-up || failed
make apply-manifests || failed

echo "Waiting for services to be up"

sleep 20

curl http://localhost:8080 | grep "Welcome" || failed

echo "Test succeded"
teardown