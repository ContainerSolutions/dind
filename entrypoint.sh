#!/bin/bash
export HTTP_PORT=${HTTP_PORT:-7777}
([[ $LOG = file ]] && { exec > /var/log/entrypoint.log; exec 2>&1; } # redirecting output to file if requested
    wrapdocker &
    # wait for docker service to respond
    while ! docker ps > /dev/null 2>&1
        do sleep 1
    done
    # start logspout
    /bin/logspout &
)
# stream logspout output
while ! (stdbuf -o0 curl -s localhost:${HTTP_PORT}/logs | stdbuf -o0 tail -n+2)
    do sleep 1 # wait for logspout to open http port
done
