kube-get-manifest-kinds() {
  local manifests="$(find $1 -name "*.y*ml" | grep -v kustomization)"
  manifest_resources="$(while IFS= read -r line; do cat "$line" | yq -s '.[] | { apiGroup: (.apiVersion | split("/")[0] | split("v1")[0] ), kind }' -c; done <<< "$manifests")"
  echo "${manifest_resources}" | sort | uniq
}

kube-get-rbac-rules-for-manifest-apply() {
  local tmpfile="$(mktemp)"
  manifestkinds="$(kube-get-manifest-kinds $1)"
  # TODO : convert to plural properly as required by rbac formatting for the resource kind, maybe with the help of kubectl api-resources. 
  # This is currently an ugly hack and some resources (e.g. policies, prometheuses) won't work properly
  echo "$manifestkinds" | sort | uniq | jq -s '{ rules: [.[] | { apiGroups: [ .apiGroup ], resources: [ ( .kind | ascii_downcase ) + "s" ], verbs: ["create","get","list","watch","update","patch","delete"] }]}' | yq -y .
}

kube-get-manifest-role-rules() {
  local manifests="$(find $1 -name "*.y*ml" | grep -v kustomization)"
  rules=$(while IFS= read -r line; do cat "$line" | yq -sy "{ rules: [.[] | select(.kind == \"ClusterRole\" or .kind == \"Role\") | .rules[]]}"; done <<< "$manifests")
  echo "$rules" | yq -sy ".[]"
}

# main alias that invokes all the others
# this generates rbac rules to be able to apply kubernetes yaml files in the specified folders
kube-manifests-rules() {
  rulesfile="$(mktemp)"
  for directory in "${@}"; do
     manifestrules="$(kube-get-manifest-role-rules "$directory" | fl)"
     rbacrules="$(kube-get-rbac-rules-for-manifest-apply "$directory" | fl)"
     echo "$manifestrules" >> "$rulesfile"
     echo "$rbacrules" >> "$rulesfile"
  done
  cat "$rulesfile"
}
