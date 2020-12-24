# 说明

> 这个仓库主要基于简单的go-app来演示如何构建自己的go-app镜像以及如何部署到k8s中



## 无状态go应用

### 创建go的初始化环境

```shell
# 国内用户需要更改goproxy
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn
go mod init go-docker
```

### 编写go-app的主程序

`main.go`

### 编写`Dockerfile`

`Dockerfile`

### 构建docker镜像

```shell
#1 使用dockerhub的直接登录即可
docker login
#1.1 使用私有镜像仓库的
docker login xx.xx.xx

#2 构建镜像
docker build -t xx.xx.xx/rke-lab/go-docker:v1.0  . 
#3 上传镜像
docker push xx.xx.xx/rke-lab/go-docker:v1.0
```



### 编写deployment

`k8s-deployment.yaml`

```shell
#1 创建deployment
kubectl create -f k8s-deployment.yaml

#2 查看
kubectl get deploy,svc,pod

#3 port-forward 对应服务
kubectl port-forward svc/go-docker 8080:80

#4 本地验证
curl http://localhost:8080/?name=xxx

```



## 有状态的go应用



### 更新main.go（定义log文件及归档策略）

`main.go`



### 更新Dockerfile(添加volume)

`Dockerfile`

```shell
#1 重新构建
docker build -t xx.xx.xx/rke-lab/go-docker:v2.0  . 
#3 上传镜像
docker push xx.xx.xx/rke-lab/go-docker:v2.0
```



### 编写statefulset

`k8s-statefulset.yaml`

```shell
#1 创建sts
kubectl create -f k8s-statefulset.yaml

#2 查看
kubectl get sts,svc,pod,pvc                                     
NAME                         READY   AGE
statefulset.apps/go-docker   2/2     2m53s

NAME                                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/go-docker-headless                         ClusterIP   None            <none>        80/TCP     2m53s
service/go-docker-public                           ClusterIP   10.43.151.127   <none>        80/TCP     2m53s

NAME              READY   STATUS    RESTARTS   AGE
pod/go-docker-0   1/1     Running   0          2m53s
pod/go-docker-1   1/1     Running   0          2m26s

NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/applog-go-docker-0   Bound    pvc-8d1ebd7e-cdee-46e7-9ad6-4cf02303769b   1Gi        RWO            longhorn       2m53s
persistentvolumeclaim/applog-go-docker-1   Bound    pvc-56c984f2-0b68-43ce-8446-193cef2af8c2   1Gi        RWO            longhorn       2m26s


#3 为service开启port-forward
kubectl port-forward svc/go-docker-public 8080:80               
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
Handling connection for 8080

#4 本地验证
❯ curl http://localhost:8080/\?name\=Sammi
Hello, Sammi

❯ curl http://localhost:8080/\?name\=Tiiiim
Hello, Tiiiim

#5 查看日志
❯ kubectl exec -it sts/go-docker -- sh
~ #
~ # cat /app/logs/app.log
2020/12/23 13:16:51 Starting Server
2020/12/23 13:21:25 Received request for Sammi
2020/12/23 13:21:32 Received request for Tiiiim

#6 手动删除一个pod，验证数据持久化
❯ kubectl delete pod/go-docker-1
pod "go-docker-1" deleted
❯ kubectl get po
NAME          READY   STATUS    RESTARTS   AGE
go-docker-0   1/1     Running   0          9m57s
go-docker-1   1/1     Running   0          35s

```
