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
