#!/bin/sh

pushd ..

# VirtualService
# NOTE: To reproduce the issue, there MUST be at least one (any) Upstream that is referenced by a VirtualService to trigger the webhook.
#       Referencing the Upstream from only the HTTPRoutes does not trigger the webhook (and I don't really know why not).
printf "\nDeploy VirtualService ...\n"
# NOTE: The VirtualService we are deploying is unrelated to the Service that we're going to remove to trigger the actual problem.
#       It is simply there to trigger the webhook on Upstreams.
kubectl apply -f virtualservices/api-example-com-vs.yaml

sleep 1

# Delete the httpbin-2 API so the httpbin-2-httpbin-2-upstream goes into error state
kubectl delete -f apis/httpbin-2.yaml

printf "\n\n\nWe have removed the httpbin-2 service, which will put the httpbin-2-httpbin-2-8000 Upstream into warning state.\n\n\n"

sleep 3

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