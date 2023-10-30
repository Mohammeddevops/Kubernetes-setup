#!/bin/bash
##################################################################
# 	            Kubernetes installation			 #
##################################################################

sudo su
sudo apt-get update && apt-get upgrade
sudo apt-get upgrade

##################################################################
#                   Successfully updated                         #
##################################################################



##################################################################
#                      Installing Docker                     	 #
##################################################################

sudo apt install docker.io
docker --version
sudo systemctl start docker
sudo systemctl enable docker

##################################################################
#                 Docker installed Successfully 		 # 
##################################################################


sudo swapoff -a
sudo apt-get update && apt-get upgrade

###########################################################################################
#	apt-transport-https may be a dummy package; if so, you can skip that package      #
###########################################################################################

sudo apt-get install -y apt-transport-https ca-certificates curl gpg
mkdir -p /etc/apt/keyrings/
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && apt-get upgrade
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

####### upto her both in master and node #######

curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.3/manifests/calico.yaml -O
kubectl apply -f calico.yaml

##################################################################
#                       Deployment.yml		 		 # 
##################################################################

cat << EOF > deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cicd-app
spec:
  replicas: 1  # Initial replicas
  selector:
    matchLabels:
      app: cicd-app
  template:
    metadata:
      labels:
        app: cicd-app
    spec:
      containers:
      - name: cicd-app
        image: mohammedsait/insurance-web-app-cicd  # Replace with your Docker image name and tag
        ports:
        - containerPort: 8080  # Assuming your app listens on port in Dockerfile
EOF

ls
kubectl apply -f deplyment.yml

##################################################################
#                          Service.yml	    			 # 
##################################################################

cat << EOF > service.yml
apiVersion: v1
kind: Service
metadata:
  name: cicd-app
spec:
  selector:
    app: cicd-app
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080  # Assuming your app runs on port which is set in the Dockerfile
  type: NodePort  # Expose the service outside the cluster
EOF

ls
kubectl apply -f service.yml

echo "Kubernetes setup completed successfully."

####### run this below command on master ###########

kubeadm init


