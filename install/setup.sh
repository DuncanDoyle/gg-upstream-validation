#!/bin/sh

pushd ..

# Deploy the Gateways

# Gloo Edge API
kubectl apply -f gateways/gateway-proxy.yaml
#K8S Gateway API
kubectl create namespace ingress-gw --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f gateways/gw.yaml

# Create namespaces if they do not yet exist
# kubectl create namespace ingress-gw --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace httpbin --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace httpbin-2 --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace httpbin-3 --dry-run=client -o yaml | kubectl apply -f -


#Label namespaces to be watched by Gloo
kubectl label namespaces gloo-system --overwrite gloo="enabled"
kubectl label namespaces default --overwrite gloo="enabled"
kubectl label namespaces httpbin --overwrite gloo="enabled"
kubectl label namespaces httpbin-2 --overwrite gloo="enabled"
kubectl label namespaces httpbin-3 --overwrite gloo="enabled"

# Label the default namespace, so the gateway will accept the HTTPRoute from that namespace.
printf "\nLabel default namespace ...\n"
kubectl label namespaces default --overwrite shared-gateway-access="true"

# Deploy the HTTPBin application
printf "\nDeploy HTTPBin application ...\n"
kubectl apply -f apis/httpbin.yaml
kubectl apply -f apis/httpbin-2.yaml

# Reference Grants
printf "\nDeploy Reference Grants ...\n"
kubectl apply -f referencegrants/httpbin-ns/default-ns-httproute-service-rg.yaml
kubectl apply -f referencegrants/httpbin-2-ns/default-ns-httproute-service-rg.yaml
kubectl apply -f referencegrants/httpbin-3-ns/default-ns-httproute-service-rg.yaml
kubectl apply -f referencegrants/gloo-system-ns/default-ns-httproute-upstream-rg.yaml

# Upstreams
kubectl apply -f upstreams/httpbin-upstream.yaml
kubectl apply -f upstreams/httpbin-2-upstream.yaml

# HTTPRoute
printf "\nDeploy HTTPRoute ...\n"
kubectl apply -f routes/api-example-com-httproute.yaml
kubectl apply -f routes/httpbin-example-com-httproute.yaml
kubectl apply -f routes/developer-example-com-httproute.yaml

popd