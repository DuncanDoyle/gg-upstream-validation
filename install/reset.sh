#!/bin/sh

pushd ../

kubectl apply -f apis/httpbin-2.yaml

kubectl delete -f apis/httpbin-3.yaml

kubectl delete -f upstreams/httpbin-3-upstream.yaml

kubectl delete -f virtualservices/api-example-com-vs.yaml

popd