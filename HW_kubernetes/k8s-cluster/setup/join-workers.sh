#!/bin/bash
# Пример (подставь реальную команду из вывода init-master.sh)
sudo kubeadm join 192.168.1.10:6443 --token abcdef.1234567890abcdef \
    --discovery-token-ca-cert-hash sha256:abcdef123456...

# данные вносим получив их из результатов выполнения init-master.sh 
