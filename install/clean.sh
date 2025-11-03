#!/bin/sh

pushd ..

kubectl delete -f virtualservices/
kubectl delete -f routes/
kubectl delete -f upstreams/
kubectl delete -f apis/

popd