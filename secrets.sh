# shows values available in a secret
kskeys() {
 k get secret -o json $1 | jq -r ".data | keys" 
}

# shows decoded secret values
ksdecode() {
  k get secret -o json $1 | jq -r "[.data | to_entries[] | { (.key): (  .value | @base64d ) }]" 
}
