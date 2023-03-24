echo "source <(kind completion bash)" >> ~/.bashrc
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -F __start_kubectl k" >> ~/.bashrc

echo "export PATH=~/.kubectx:$PATH" >> ~/.bashrc
echo "alias kx=kubectx" >> ~/.bashrc
echo "alias kns=kubens" >> ~/.bashrc