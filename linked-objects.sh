
# finds all volumes of particular type attached to pods
kube-vols() {
  local volType="${1:-'pass vol type as first arg'}"
  shift
  k get po -o json ${@} | jq "[.items[] | { name: .metadata.name, vols: .spec.volumes } | select(.vols[] | has(\"$volType\")) | { pod: .name, vols: [.vols[].name] }]"
}

k-netpol-pods() {
  NETPOL=$1
  shift
  k get netpol $NETPOL -o json | jq '[.spec.podSelector.matchLabels | to_entries | .[] | .key + "=" + .value] | join(",")' | xargs kubectl get po "${@}" -l
}

k-svc-pods() {
  SVC=$1
  shift
  k get svc $SVC -o json | jq '[.spec.selector | to_entries | .[] | .key + "=" + .value] | join(",")' | xargs kubectl get po "${@}" -l
}

k-ingress-svcs() {
  INGRESS=$1
  shift
  k get ingress $INGRESS -o json | jq '[.spec.rules[].http.paths[].backend.service.name] | join(" ")' | xargs kubectl get svc "${@}" 
}

k-ingress-pods() {
  INGRESS=$1
  shift
  SVC="$(k get ingress $INGRESS -o json | jq -r '[.spec.rules[].http.paths[].backend.service.name] | join(" ")')"
  # TODO need to do an OR between different svcs, this does an AND so only works where the ingress has a single service
  # also returned json may be different when we get multiple svcs
  # svcs may also be attached to an explicitly defined endpoint, without a director. we fail in this case
  k-svc-pods $SVC "${@}"
}
