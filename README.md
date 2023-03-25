# Kyverno Demo

![Kyverno](images/kyverno.png)

## Setup

### devcontainer
This demo shows how to use Kyverno to enforce policies on Kubernetes resources. You can use the devcontainer following this repo. The devcontainer has all the tools installed to run the demo. 

### Setting up the demo without the devcontainer
First, you will need to have _kind_ installed. You can find instructions on how to install _kind_ [here](https://kind.sigs.k8s.io/docs/user/quick-start/).


## Create a cluster
To create a cluster, run the following command:

```bash
kind create cluster --name kyverno-demo
```

### Get the kubeconfig

```bash
kind get kubeconfig --name kyverno-demo > ~/.kube/config
```

### Install Kyverno
To install Kyverno, run the following command:

```bash
kubectl apply -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
```

## Demo

First we will create a namespace for our demo pods:
    
```bash
kubectl apply -f demo-pods/ns.yaml
kubectl apply -f demo-pods/missing-tech-lead-label.yaml
```

We should then see the following output:
    
```bash
    Error from server: error when creating "demo-pods/missing-tech-lead-label.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

    policy Pod/demo-pods/failing-demo for resource violation: 

    require-labels:
    check-for-labels: 'validation error: The label `tech-lead` is required. rule check-for-labels
        failed at path /metadata/labels/tech-lead/'
```