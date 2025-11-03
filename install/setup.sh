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

# Wait for the upstreams to be deployed before we deploy the VS. If we deploy this too early, it will trigger the webhook.
sleep 3

# VirtualService
# NOTE: To reproduce the issue, the invalid upstream MUST be referenced by a VirtualService to trigger the webhook.
#       Referencing the Upstream from only the HTTPRoute does not trigger the webhook (and I don't really know why not).
printf "\nDeploy VirtualService ...\n"
kubectl apply -f virtualservices/httpbin-example-com-vs.yaml

popd