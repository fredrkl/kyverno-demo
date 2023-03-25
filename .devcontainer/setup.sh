cat >> ~/.bashrc <<EOF
source <(kind completion bash)
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k

export PATH=~/.kubectx:$PATH
alias kx=kubectx
alias kns=kubens
EOF

mkdir ~/.kube