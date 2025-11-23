# HW_kubernetes

## Gerasin Dmitrii

---
```
mkdir k8s-cluster && cd k8s-cluster

```
---
Общая структура

---
```
k8s-cluster/
├── setup/               # Скрипты установки
│   ├── install-tools.sh
│   ├── init-master.sh
│   └── join-workers.sh
├── cni/
│   └── calico.yaml      # Манифест CNI
├── manifests/
│   └── test-nginx.yaml  # Проверка работы
└── docs/
    └── ARCHITECTURE.md  # Краткая схема


```

---


устанавливаем утилиты на всех нодах.

 
 Пишем скрипт setup/install-tools.sh

```#!/bin/bash
# Отключаем swap
sudo swapoff -a
sudo sed -i '/swap/s/^/#/' /etc/fstab

# Включаем модули ядра
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Настройка sysctl
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

# Установка containerd
sudo apt-get update
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Установка kubeadm, kubelet, kubectl
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

```
---
Пишем скрипт

```
#!/bin/bash
# Отключаем swap
sudo swapoff -a
sudo sed -i '/swap/s/^/#/' /etc/fstab

# Включаем модули ядра
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# Настройка sysctl
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system

# Установка containerd
sudo apt-get update
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Установка kubeadm, kubelet, kubectl
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

```
---
Пишем скрипт setup/init-master.sh

```
#!/bin/bash
# Инициализируем кластер
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Настройка kubectl для пользователя
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Вывод команды для подключения воркеров
echo "=== Команда для воркеров ==="
kubeadm token create --print-join-command

```
---

Ставим калио, CNI (Cflio), создаем файл изапускаем под командой

```
cni/calico.yaml

```
важно CIDR должен совпадать с тем который указан в kubeadm init

```
apiVersion: projectcalico.org/v3
kind: Installation
meta
  name: default
spec:
  calicoNetwork:
    ipPools:
      - cidr: 192.168.0.0/16
        blockSize: 26


``` 
kubectl apply -f cni/calico.yaml

``` 
---
подключаем воркеры 

Файл  setup/join-workers.sh   заполнить после init-master.sh


```
#!/bin/bash
# Пример (подставь реальную команду из вывода init-master.sh)
sudo kubeadm join 192.168.1.10:6443 --token abcdef.1234567890abcdef \
    --discovery-token-ca-cert-hash sha256:abcdef123456...

```
вводим команды проверкир работоспособности и стабильности.

```
kubectl get nodes           # Должны быть Ready
kubectl get pods -A         # Все системные поды — Running

```
---

создаем и запускаем тестопый под.

Создаем манифест файл manifests/test-nginx.yaml

```
apiVersion: apps/v1
kind: Deployment
meta
  name: nginx-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    meta
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
meta
  name: nginx-svc
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP

``` 
Запускаем под 

```
kubectl apply -f manifests/test-nginx.yaml

```
