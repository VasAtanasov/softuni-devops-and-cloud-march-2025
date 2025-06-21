#!/bin/bash

docker run -it --rm \
  --name city-search \
  --network pg-net \
  city-search "$1"