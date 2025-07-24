This repository only deploy two kubernetes nodes with all configuration required like kuberenets repo to install kubectl, kubeadm and kubelet services, docker, httpd, etc. 
You only need to do few steps like create a token in master node by running "kubeadm token create --print-join-command" and copy that token from master node and paste it to the worker node, for connection of master node and worker node. 
And then enter kubectl get nodes command in master node, it will show you that worker node is connected to master node.
After that you need to aplly flannel which is mentioned in master node's script.
