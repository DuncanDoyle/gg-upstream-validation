#!/bin/sh

pushd ..

# Delete the httpbin-2 API so the httpbin-2-httpbin-2-upstream goes into error state
kubectl delete -f apis/httpbin-2.yaml

# Deploy the httpbin-3 api
kubectl apply -f apis/httpbin-3.yaml
# And the related upstream. This will now trigger the issue
kubectl apply -f upstreams/httpbin-3-upstream.yaml 

printf "\n\n\nObserve that the upstream for another service, unrelated to the service that was just removed, cannot be created!!!!\n\n\n"

sleep 3

printf "\nRecreate service that is referenced by httpbin-2-httpbin-2-upstream to get the Upstream resource out of the error state.\n\n"
kubectl apply -f apis/httpbin-2.yaml

sleep 3

printf "\nAnd now the Upstream httpbin-3-httpbin-3-8000 can be created.\n\n"
kubectl apply -f upstreams/httpbin-3-upstream.yaml 

popd