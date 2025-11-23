# HW_kubernetes

## Gerasin Dmitrii

В рамках выполнения домашнего задания по созданию и развертыванию кластера
пишем проект.
---
---
для создания кластера необходимо в рамках этой работы

создаем пару виртуальных машин в облаке или локально, машины должны находится как минимум в одной зане или локально 

--- 
yc-cloud ниже последовательность и команды

---


создаем и запускаем пару машин 

```
#!/bin/bash

# Проверяем количество переданных аргументов
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <имя_виртуальной_машины>"
    echo "Пример: $0 ansible1"
    exit 1
fi

# Получаем имя ВМ из аргумента
VM_NAME="$1"

set -e

create-vm() {
    local  # Объявляем локальные переменные
        ZONE="ru-central1-b" \
        SUBNET="default-ru-central1-b" \
        SSH_KEY_PATH="$HOME/.ssh/ssh-key-1763193011987.pub"
    
    # Создаем ВМ с указанными параметрами
    yc compute instance create \
        --name "$VM_NAME" \
        --hostname "$VM_NAME" \
        --zone "$ZONE" \
        --network-interface subnet-name="$SUBNET",nat-ip-version=ipv4 \
        --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts \
        --memory 4GB \
        --cores 2 \
        --ssh-key "$SSH_KEY_PATH"
}

# Вызываем функцию создания ВМ
create-vm
```
---
скрипт запускаем с аргументом. аргумент имя машины . подключаемся к машинам 


```
yc compute instance list

```
проверяем сети

открываем второй терминал что бы параллельно  разворачивать две ноды
```
ssh yc-user@......
ssh yc-user@......
```


---
разворачиваем на них архитектуру

```
nano arh.sh \ chmod +x arh.sh

```
---
запускать скрипт с аргументами но скрипт другой или строить руками как кому удобно




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
```
#!/bin/bash

# Создаем основную директорию проекта
mkdir k8s-cluster
cd k8s-cluster || exit

# Создаем основные директории
mkdir setup
mkdir cni
mkdir manifests
mkdir docs

# Создаем поддиректории setup
touch setup/install-tools.sh
touch setup/init-master.sh
touch setup/join-workers.sh

# Создаем файлы CNI
touch cni/calico.yaml

# Создаем файлы манифестов
touch manifests/test-nginx.yaml

# Создаем документацию
touch docs/ARCHITECTURE.md

# Добавляем базовый контент в install-tools.sh
cat <<EOF > setup/install-tools.sh
#!/bin/bash

echo "Установка необходимых инструментов..."
sudo apt-get update
sudo apt-get install -y \
    docker.io \
    kubeadm \
    kubectl \
    kubelet
EOF

# Добавляем базовый контент в init-master.sh
cat <<EOF > setup/init-master.sh
#!/bin/bash

echo "Инициализация мастера Kubernetes..."
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p \$HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config
sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config
EOF

# Добавляем базовый контент в join-workers.sh
cat <<EOF > setup/join-workers.sh
#!/bin/bash

echo "Скрипт для присоединения воркеров"
# Здесь будет команда присоединения воркеров
# Пример: kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
EOF

# Добавляем базовый контент в ARCHITECTURE.md
cat <<EOF > docs/ARCHITECTURE.md
# Архитектура Kubernetes кластера

## Компоненты кластера

### Мастер-нода
* API Server
* Controller Manager
* Scheduler
* Etcd

### Воркер-ноды
* Kubelet
* Kube-proxy
* Container Runtime (Docker/containerd)

## Сетевая архитектура
* CNI плагин: Calico
* Pod CIDR: 192.168.0.0/16

## Ресурсы
* [Документация Kubernetes](https://kubernetes.io)
* [Документация Calico](https://docs.projectcalico.org)
EOF

# Делаем скрипты исполняемыми
chmod +x setup/*.sh

echo "Структура Kubernetes проекта создана успешно!"
```

---


устанавливаем утилиты на всех нодах.

---
ставим компоненты  doker

```
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

```
```

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

```
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

```
sudo systemctl status docker

```
sudo systemctl start docker

```
sudo docker run hello-world

```
---
проверяем работоспособность и настройки conteinerd

---
# Проверка установки containerd
sudo systemctl status containerd

# Если сервис не активен, запустите его
sudo systemctl start containerd
sudo systemctl enable containerd

# Проверка конфигурации
sudo containerd config default > /etc/containerd/config.toml

# Перезапуск сервиса
sudo systemctl restart containerd

# Проверка статуса
sudo systemctl status containerd




---


 Пишем скрипт setup/install-tools.sh

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

проверяем работоспособность и настройки conteinerd можно перед вводом команды на инициализацию 
но либо докер либо кортейнерд должны работать корректно


---
# Проверка установки containerd
sudo systemctl status containerd

# Если сервис не активен, запустите его
sudo systemctl start containerd
sudo systemctl enable containerd

# Проверка конфигурации
sudo containerd config default > /etc/containerd/config.toml

# Перезапуск сервиса
sudo systemctl restart containerd

# Проверка статуса
sudo systemctl status containerd

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

