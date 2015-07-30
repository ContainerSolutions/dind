#!/bin/bash
export HTTP_PORT=7777
([[ $LOG = file ]] && { exec > /var/log/entrypoint.log; exec 2>&1; } # redirecting output to file if requested
  wrapdocker &
  while ! docker ps > /dev/null
    do sleep 1 # wait for docker service to get ready
  done
  /bin/logspout &
)
while ! (stdbuf -o0 curl -s localhost:${HTTP_PORT}/logs | stdbuf -o0 tail -n+2)
  do sleep 1 # wait for logspout to open http port
done
