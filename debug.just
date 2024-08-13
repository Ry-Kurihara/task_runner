@build_python:
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
  docker run -v $(pwd):/app --rm scripts_pyenv:latest python --version