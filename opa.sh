alias kopa-pols="k get constrainttemplates -o json -A | jq -r '.items[].spec.crd.spec.names.kind'"

kopa-audit() {
  k get "$1" -o json | jq '[.items[].status.violations[] | { resource: (.namespace + "/" + .name), msg: .message, action: .enforcementAction }]'
}
