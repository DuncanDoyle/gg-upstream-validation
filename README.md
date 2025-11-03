# Gloo Gateway Reproducer Template

## Installation

Add Gloo Gateway Helm repo:
```
helm repo add glooe https://storage.googleapis.com/gloo-ee-helm
```

Export your Gloo Gateway License Key to an environment variable:
```
export GLOO_GATEWAY_LICENSE_KEY={your license key}
```

Install Gloo Gateway:
```
cd install
./install-gloo-gateway-with-helm.sh
```

> NOTE
> The Gloo Gateway version that will be installed is set in a variable at the top of the `install/install-gloo-gateway-with-helm.sh` installation script.

## Setup the environment

Run the `install/setup.sh` script to setup the environment:

- Create the required namespaces
- Deploy the Gateways (Gloo Egde API and K8S Gateway API)
- Deploy the HTTPBin applications
- Deploy the Reference Grants
- Deploy the VirtualService (Gloo Edge API)
- Deploy the HTTPRoutes (K8S Gateway API)

```
./setup.sh
```

## Issue Reproducer

Run `./trigger-issue.sh` to run through the sequence of deployments and deletions that triggers the "problem". What happens is that the script will:
- delete a Service that is referenced by an Upstream that is referenced by a VirtualService.
- Deploy a new, unrelated, Service.
- Deploy a new Upstream that references this new Service.

Due to the fact that by deleting that initial Service, we've put the Upstream that referenced it in an Error state, we can now no longer create our new Upstream that references our new Service.

Note that this state only seems to get triggered when the Upstream that is in Error state is referenced by a VirtualService. If that Upstream is not reference by a VirtualService, but only by a HTTPRoute, the validating webhook does not block the deployment of our new Upstream.