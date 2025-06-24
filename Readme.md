This repository only deploy two kubernetes nodes with all configuration required like kuberenets repo, docker, httpd, etc. 
You only need to do two steps like create and copy a token from master node and paste it to the worker node. 
And then enter kubectl get nodes command in master node, it will show you that worker node is connected to master node.
After that you need to aplly flannel which is mentioned in master node's script.
