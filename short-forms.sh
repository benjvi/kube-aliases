# basics
alias k=kubectl

# run apps easily

# get stuff lazily
alias kgp="k get pods"
alias kgd="k get deploy"
alias kgs="k get svc"

# make manifest operations easier
alias ka="k apply -f"
alias kd="k delete -f"

# from 1.18 onwards run can only create pods 
alias kcp="k run"
alias kcd="k create deployment"
alias kcj="k create job"
alias kccj="k create cronjob --schedule '00 00 * * *'"

# change your namespace / context
alias kns="k config set-context --current --namespace"  # only in recent versions
alias kctxs="k config get-contexts"
alias kuctx="k config use-context"
alias kctx='kctxs | grep -e "*" -e "NAMESPACE"'
alias kcx=kctx

# docs
alias kexpl="k explain"
alias kexplr="k explain --recursive"
alias kattr="k explain --recursive"
alias kschema="k explain --recursive"

# TODO: pv / pvc?


# TODO: creating network policies

# creating services
alias kexd="k expose deploy"
alias kexp="k expose pod"
alias kexrs="k expose rs"

# deleting a pod
alias kdp="k delete pod --grace-period=0 --force"

# updating things
# adding volume to a pod
# adding labels to things
# use -l option on create or use kubectl label

# patching things
# TODO
