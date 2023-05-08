#!/bin/bash

export HUGO_RESOURCEDIR="$(pwd)/resources"
hugo  serve --buildDrafts --buildFuture --environment "development" --config "$(pwd)"/hugo.toml
