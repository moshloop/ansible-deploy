#!/usr/bin/env bats

@test "environment var is saved" {
  cat /etc/environment | grep key1=value1
}

@test "environment var is updated" {
  cat /etc/environment | grep key2=value3
}

@test "environment var is not duplicated" {
    ! cat /etc/environment | grep key2=value2
}
