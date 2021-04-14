# does a groupby on the specified path, output in k-v format by group
kgroupby() { 
  ymlpath="$1"
  GROUPED="$(yq -y "[ .[] |  select(.$ymlpath)] | [ group_by(.${ymlpath})[] | { (.[0] | .${ymlpath}): . }] | add")"
  echo "$GROUPED"
}

ksplit() {
  outdir="$1"
  groups="$(echo "$GROUPED" | yq "keys" | jq -r ".[]")"
  echo $groups
  while IFS= read -r group; do
     echo "$GROUPED" | yq -y ".[\"$group\"][]" >  "$outdir/$group.yml"
  done <<< "$groups"
}

kshard-onlist() {
  yq -y ".items" | kshard
}

# reads in yaml from a single file
# does a groupby with the specified (yq) path
# then writes groups to separate files in the specified output directory
# interesting examples:
# kshard "metadata.namespace" test
# kshard kind test
# TODO: fixme, this is broken in some scenarios right now
kshard() {
  ymlpath="$1"
  outdir="$2"
  yaml="$(yq -y ".")"
  echo "$yaml"
  grouped="$(echo "$yaml" | kgroupby "$ymlpath")"
  echo "$grouped" | ksplit "$outdir"
  ungrouped="$(echo "$yaml" | yq -y ".[] |  select(.$ymlpath | not)")"
  echo "$ungrouped" > "$outdir/none.yml"
}
