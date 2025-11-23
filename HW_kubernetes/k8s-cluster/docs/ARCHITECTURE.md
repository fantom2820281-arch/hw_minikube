# Последовательность построения структуры 
## это для тех кто так же как и я это делает первый раз. 

### тут создание и запуск виртуальной машины.

---
---


---
---

### когда машина создана и подключился строим структуру базовую

---

```
mkdir -p k8s-cluster/{setup,cni,manifests,docs} && \
cd k8s-cluster && \
touch setup/{install-tools.sh,init-master.sh,join-workers.sh} && \
touch cni/calico.yaml && \
touch manifests/test-nginx.yaml && \
touch docs/ARCHITECTURE.md


```


редактируем файлы, пишем все встраиваем 

 

### запускаем 

---
---
yc-user@fhmueaaks8glvubjuf46:~/k8s-cluster$ tree -L 2
.
├── cni
│   └── calico.yaml
├── docs
│   └── ARCHITECTURE.md
├── manifests
│   └── test-nginx.yaml
└── setup
    ├── init-master.sh
    ├── install-tools.sh
    └── join-workers.sh

5 directories, 6 files
yc-user@fhmueaaks8glvubjuf46:~/k8s-cluster$

устанавливаем docker 


```
перед запуском проверяем структуру, делаем все файлы .sh исполняемыми


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
yc-user@fhmueaaks8glvubjuf46:~/k8s-cluster/setup$ ./init-master.sh
sudo: kubeadm: command not found
cp: cannot stat '/etc/kubernetes/admin.conf': No such file or directory
=== Команда для воркеров ===
./init-master.sh: line 12: kubeadm: command not found
yc-user@fhmueaaks8glvubjuf46:~/k8s-cluster/setup$ 
```
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
```
---

```
# Добавляем репозиторий Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y apt-transport-https

# Создаем файл с настройками репозитория
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Обновляем систему и устанавливаем компоненты
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

```Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.128.0.22:6443 --token 99xe8a.vwxs4d613w03m77b \
        --discovery-token-ca-cert-hash sha256:f47bf315aa13283290996a3ca67bd0d4789f18fe21ca376e38561b5250126637 
cp: overwrite '/home/yc-user/.kube/config'? y
=== Команда для воркеров ===
kubeadm join 10.128.0.22:6443 --token q40g8z.7k22nd77pt6xsydk --discovery-token-ca-cert-hash sha256:f47bf315aa13283290996a3ca67bd0d4789f18fe21ca376e38561b5250126637 cd

###  


--- 
сети 

```
dima@house:~/githab/netology_hw/HW_kubernetes$ yc vpc network list
+----------------------+---------------+
|          ID          |     NAME      |
+----------------------+---------------+
| enp7b7iajk65ssntg9lv | my-yc-network |
| enpod97lvd6mdq7t62q8 | default       |
+----------------------+---------------+

dima@house:~/githab/netology_hw/HW_kubernetes$ yc vpc subnet list
+----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
|          ID          |         NAME          |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |      RANGE      |
+----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
| e2l9ktm0sih51kstgnol | default-ru-central1-b | enpod97lvd6mdq7t62q8 |                | ru-central1-b | [10.129.0.0/24] |
| e9bcassh9lna9sq1bepg | my-yc-subnet-a        | enp7b7iajk65ssntg9lv |                | ru-central1-a | [10.1.2.0/24]   |
| e9bgfj810k39g70t4hur | default-ru-central1-a | enpod97lvd6mdq7t62q8 |                | ru-central1-a | [10.128.0.0/24] |
| fl8kf9h91es2mt547c51 | default-ru-central1-d | enpod97lvd6mdq7t62q8 |                | ru-central1-d | [10.130.0.0/24] |
+----------------------+-----------------------+----------------------+----------------+---------------+-----------------+

dima@house:~/githab/netology_hw/HW_kubernetes$ 

---
---
