#!/bin/bash

os_name="$(uname -s)"
case "${os_name}" in
  Linux*)
    NETCAT=nc
    ;;
  Darwin*)
    NETCAT=ncat    # 'nc' isn't reliable on macOS
    ;;
  *) echo "Unsupported operating system: $os_name"
     exit 1
     ;;
esac

[ -z "$REST_API_ENDPOINT" ]  &&  REST_API_ENDPOINT=localhost:8008
echo REST_API_ENDPOINT is $REST_API_ENDPOINT

host=`echo $REST_API_ENDPOINT | cut -d: -f1`
port=`echo $REST_API_ENDPOINT | awk -F: '{print $2}'`

$NETCAT -z -w 2 $host $port  &&  {
  consensus=`curl http://$REST_API_ENDPOINT/blocks | grep consensus | sed 's/^.*://' | cut -d \" -f2`
  rc=$?
  [ $rc = 0 ]  &&  {
    for c in $consensus
    do
      decoded_data=`echo $c | base64 --decode`
      decoded_epoch_time=`echo $decoded_data | awk -F: '{print $NF}'`
      echo `date +"%Y-%m-%d %H:%M:%S" -d @$decoded_epoch_time` $decoded_data    # display timestamp in human-readable format
    done
  }
}  ||  {
  echo "Endpoint $REST_API_ENDPOINT isn't open."
  rc=1
}

exit $rc