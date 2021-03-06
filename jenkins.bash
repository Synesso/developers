#! /usr/bin/env bash
set -e

cat <<-EOS > build-node.bash
  set -e
  cd "\$(dirname "\$0")"
    
  rollback() {
    echo "rolling back"
    set +e
    rm -rf node_modules
    rm -rf bower_components
    rm -rf build 
    rm -rf repos
    rm build-node.bash
  }

  trap rollback INT TERM EXIT ERR

  # allow bower to run inside docker
  echo '{ "allow_root": true }' > /root/.bowerrc

  npm install -q -g gulp bower
  bower install -q
  chown -R ${UID} ./bower_components

  npm install -q 
  chown -R ${UID} ./node_modules

  rm -rf ./repos/
  gulp --pathPrefix="/developers"
  chown -R ${UID} ./build

  rm build-node.bash

  trap - INT TERM EXIT ERR
EOS

docker run \
  --rm \
  -v $(pwd):/app \
  node:4 /bin/bash /app/build-node.bash 


