cat >> ~/.bashrc <<EOF
source <(kind completion bash)
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k

export PATH=~/.kubectx:$PATH
alias kx=kubectx
alias kns=kubens
export PATH=~/.krew/bin:$PATH
EOF

curl -LO https://github.com/kyverno/kyverno/releases/download/v1.7.2/kyverno-cli_v1.7.2_linux_x86_64.tar.gz
tar -xvf kyverno-cli_v1.7.2_linux_x86_64.tar.gz
sudo mv kyverno /usr/local/bin/
rm -rf kyverno-cli_v1.7.2_linux_x86_64.tar.gz

mkdir ~/.kube