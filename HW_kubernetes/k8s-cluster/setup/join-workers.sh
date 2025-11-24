#!/bin/bash
# Пример (подставь реальную команду из вывода init-master.sh)
kubeadm join 10.129.0.37:6443 --token v17bcz.f3tdinxe9bpvveck --discovery-token-ca-cert-hash sha256:7508d305f602d9ed814275a5bb5757dabc3027f930ad1c633f4d182164cc31bc

# данные вносим получив их из результатов выполнения init-master.sh 
