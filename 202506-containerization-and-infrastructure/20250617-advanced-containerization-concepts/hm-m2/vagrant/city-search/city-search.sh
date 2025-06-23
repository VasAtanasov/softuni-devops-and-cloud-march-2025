#!/bin/bash

docker run -it --rm --network pg-net city-search "$1"