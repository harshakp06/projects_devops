# Projects Devops

## Istio Instalation 
```
curl -L https://istio.io/downloadIstio | sh -
cd istio-1.19.3
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y && kubectl apply -f samples/addons

kubectl label namespace default istio-injection=enabled

```
Addons will install Grafana, Prometheus, Jaeger, Kiali 

Setting Context https://humalect.com/blog/kubectl-config-set-context
