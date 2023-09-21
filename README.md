# self-signed-certificate-service
This backend project provides a solution for generating self-signed certificates using the go-zero framework. 
The generated certificates are stored in the "out" directory under the current working directory. 
By default, the root certificate is only generated once, and it can be manually deleted from the directory to regenerate it if needed.

### Usage

Build Docker Image

```
docker build -t self-signed-certificate-service:v1 .
```

Run Docker Container

```
docker run --name self-signed-certificate-service \
  --restart always \
  -p 8000:8000 \
  -d self-signed-certificate-service:v1
```

Usage with Kubernetes

```
# modify self-signed-certificate-service.yaml
kubectl -n xxx apply -f self-signed-certificate-service.yaml
```
