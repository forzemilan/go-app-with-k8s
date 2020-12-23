# 说明

## 这个仓库主要基于简单的go-app来演示如何构建自己的go-app镜像以及如何部署到k8s中

> 创建无状态的go应用并部署至k8s中, git tag为v1.0

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

### 编写deployment

`k8s-deployment.yaml`
