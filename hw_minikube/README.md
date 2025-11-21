# Gerasin Dmitrii 

## HW Minikube

--- 
### 1 задание


Запустите Kubernetes локально, используя k3s или minikube на свой выбор.
Добейтесь стабильной работы всех системных контейнеров.

---

для выполнения задания посетили официальные сайты
и по инструкциям из сайтов установили docker,minikube
запустили minikube start убедились в работоспособности системы

---


![scren1](screen_1.png)

---


### 2 задание

Есть файл с деплоем

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  selector:
    matchLabels:
      app: redis
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: master
        image: bitnami/redis
        env:
         - name: REDIS_PASSWORD
           value: password123
        ports:
        - containerPort: 6379

```
  1 Измените файл с учётом условий:
      redis должен запускаться без пароля;
      создайте Service, который будет направлять трафик на этот Deployment;
      версия образа redis должна быть зафиксирована на 6.0.13.
  2  Запустите Deployment в своём кластере и добейтесь его стабильной работы.

  ---
Внесли изменения в деплой файл, 
```
apiVersion: apps/v1
kind: Deployment
meta
  name: redis-servise
spec:
  selector:
    matchLabels:
      app: redis
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: master
        image: bitnami/redis:6.0.13-alpine # Версия зафиксирована
        env:
          - name: ALLOW_EMPTY_PASSWORD
            value: "yes"  
        ports:
          - containerPort: 6379
          
```

создаем сервис файл

```
apiVersion: v1
kind: Service
meta
  name: redis
spec:
  selector:
    app: redis
  ports:
    - protocol: TCP
      port: 6379
      targetPort: 6379
  type: ClusterIP  
  
  ```

выполняем команду для разворачиваем поды

kubectl apply -f asyadeployredis.yaml
kubectl apply -f redis-service.yaml

проверяем
kubectl get pods,svc

![screen2](screen_2.png)

---
### Задание 3

Напишите команды kubectl для контейнера из предыдущего задания:
выполнения команды ps aux внутри контейнера;
просмотра логов контейнера за последние 5 минут;
удаления контейнера;
проброса порта локальной машины в контейнер для отладки.

команды для выполнения этих действий
kubectl exec -it redis-client -- ps aux после запуска пода 
kubectl exec -it redis-57f894f76c-bcl5m -- ps aux выполняем в определенном поде 

kubectl logs redis-client --since=5m логи смотрим так 

в принципе можно смотреть любых работающих проверяем что работает kubectl get pods,svc

kubectl logs redis-57f894f76c-bcl5m --since=5m

удаление подов команда delete имя

kubectl delete pod redis-client
kubectl delete deploy/redis

пробросить порт и подключиться локально

kubectl port-forward svc/redis 6379:6379

подключение

redis-cli -p 6379

происвели подключение провели тест сервис работает корректно тест прошел

результат 
![screen3](screen_3.png)

---

Есть конфигурация nginx:

```
location / {
    add_header Content-Type text/plain;
    return 200 'Hello from k8s';
}

```

---

### задание 4

Напишите yaml-файлы для развёртки nginx, в которых будут присутствовать:

ConfigMap с конфигом nginx;
Deployment, который бы подключал этот configmap;
Ingress, который будет направлять запросы по префиксу /test на наш сервис.


конфигурация

```

apiVersion: v1
kind: ConfigMap
meta
  name: nginx-config
data:
  default.conf: |
    server {
      listen 80;
      location / {
        add_header Content-Type text/plain;
        return 200 'Hello from k8s';
      }
      location /test {
        add_header Content-Type text/plain;
        return 200 'Hello from k8s /test route';
      }
    }

```
деплой
nginx-deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
meta
  name: nginx-deploy
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
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: config-volume
        configMap:
          name: nginx-config

```

сервис
nginx-service.yaml
```
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

ингрес
nginx-ingress.yaml
```
apiVersion: networking.k8s.io/v1
kind: Ingress
meta
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx  # Убедись, что контроллер установлен (minikube: minikube addons enable ingress)
  rules:
  - http:
      paths:
      - path: /test
        pathType: Prefix
        backend:
          service:
            name: nginx-svc
            port:
              number: 80

```

запуск

```
# Включаем ingress в minikube (если ещё не включён)
minikube addons enable ingress

# Применяем манифесты по порядку
kubectl apply -f nginx-configmap.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f nginx-ingress.yaml

```
проверка кроме стандартной kubectl get .....
```
minikube ip

```

открываем в браузере 

http://<minikube-ip>/test

---
---

P.S.добавить скрины

---
---
