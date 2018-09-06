#!/usr/bin/env bats

@test "service1" {
    curl host.docker.internal:8081
}

@test "service1" {
    curl host.docker.internal:8082
}