set shell := ["docker", "run", "--rm", "scripts_pyenv:latest", "python3", "-c"]

@build_python:
  #!/bin/sh
  dir=$(dirname $(realpath {{ source_file() }})) && \
  cd $dir && \
  hash_file=dockerfile.hash && \
  current_hash=$(shasum Dockerfile | awk '{ print $1 }') && \
  if [ -f $hash_file ]; then \
    previous_hash=$(cat $hash_file); \
  else \
    previous_hash=""; \
  fi && \
  if [ ! -f $hash_file ] || [ "$current_hash" != "$previous_hash" ]; then \
    echo "Dockerfile changed or hash file not found, rebuilding..." && \
    echo "Current directory: $(pwd)" && \
    docker build -t scripts_pyenv:latest . && \
    echo $current_hash > $hash_file; \
  else \
    echo "No changes detected in Dockerfile, skipping build."; \
  fi

exec_python: build_python
  #!/bin/sh
  dir=$(dirname $(realpath {{ source_file() }})) && \
  echo "Just Projcet Directory: $dir" && \
  docker run -v $dir:/app --rm scripts_pyenv:latest python /app/simple_requests.py

exec_py_direct: build_python
  import requests; \
  url = "http://google.com"; \
  response = requests.get(url); \
  print(response.text);