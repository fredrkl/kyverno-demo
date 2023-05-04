# Kyverno Demo

![Kyverno](images/kyverno.png)

# Setup

## devcontainer
This demo shows how to use Kyverno to enforce policies on Kubernetes resources. You can use the devcontainer following this repo. The devcontainer has all the tools installed to run the demo. 

## Setting up the demo without the devcontainer
First, you will need to have _kind_ installed. You can find instructions on how to install _kind_ [here](https://kind.sigs.k8s.io/docs/user/quick-start/).


# Create a cluster
To create a cluster, run the following command:

```bash
kind create cluster --name kyverno-demo
```

## Get the kubeconfig

```bash
kind get kubeconfig --name kyverno-demo > ~/.kube/config
```

# Install Kyverno

## Using Helm
Following the instructions [here](https://kyverno.io/docs/installation/#using-helm) to install Kyverno using Helm.

## Using kubectl
To install Kyverno, run the following command:

```bash
kubectl apply -f https://raw.githubusercontent.com/kyverno/kyverno/main/definitions/release/install.yaml
```

# K8s policy Demo

```bash
kubectl apply -f policies/require-tech-lead-label.yaml
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

## Report

To get a report, run the following command:

```bash
kubectl describe backgroundscanreports.kyverno.io {a-backgroundscanreport-name}
```

Example output(reduced for brevity):

```bash
Name:         194e4165-e135-49ad-8585-1c397b1cd773
Namespace:    kyverno
Labels:       app.kubernetes.io/managed-by=kyverno
              audit.kyverno.io/resource.hash=42a4837ede0daaa4e04e5a2a26ce3300
              audit.kyverno.io/resource.uid=194e4165-e135-49ad-8585-1c397b1cd773
              cpol.kyverno.io/require-labels=24562
Annotations:  audit.kyverno.io/last-scan-time: 2023-03-25T23:46:40Z
API Version:  kyverno.io/v1alpha2
Kind:         BackgroundScanReport
Metadata:
  Creation Timestamp:  2023-03-25T21:33:52Z
  Generation:          3
  Owner References:
    API Version:     v1
    Kind:            Pod
    Name:            kyverno-cleanup-controller-89d978b7c-wr544
Spec:
  Results:
    Category:  Best Practices
    Message:   validation error: The label `tech-lead` is required. rule check-for-labels failed at path /metadata/labels/tech-lead/
    Policy:    require-labels
    Result:    fail
    Rule:      check-for-labels
    Scored:    true
    Severity:  medium
    Source:    kyverno
    Timestamp:
      Nanos:    0
      Seconds:  1679788006
  Summary:
    Error:  0
    Fail:   1
    Pass:   0
    Skip:   0
    Warn:   0
Events:     <none>
```

# Kyverno CLI Demo

The kyverno cli is installed as part of this codespace. Please see the [Kyverno CLI](https://kyverno.io/docs/kyverno-cli/) documentation if you want to install it locally.

## Validate a policy

```bash
kyverno test .
```
### The result
```
codespace ➜ /workspaces/kyverno-demo (main) $ kyverno test .

Executing require tech label...
applying 2 policies to 3 resources... 
I0331 16:56:19.873155   12360 evaluate.go:63] EngineValidate "msg"="a condition failed in 'all' block" "kind"="Pod" "name"="failing-demo" "namespace"="tech-lead" "policy"="valid-image" "rule"="valid-image" "condition"={"key":["nginx"],"operator":"AnyNotIn","value":["traefik","nginx"]}
I0331 16:56:19.874060   12360 evaluate.go:63] EngineValidate "msg"="a condition failed in 'all' block" "kind"="Pod" "name"="valid-tech-lead-demo" "namespace"="tech-lead" "policy"="valid-image" "rule"="valid-image" "condition"={"key":["nginx"],"operator":"AnyNotIn","value":["traefik","nginx"]}

│───│─────────────────────────│─────────────────────│────────────────────────────────────│────────│
│ # │ POLICY                  │ RULE                │ RESOURCE                           │ RESULT │
│───│─────────────────────────│─────────────────────│────────────────────────────────────│────────│
│ 1 │ require-tech-lead-label │ check-for-tech-lead │ tech-lead/Pod/failing-demo         │ Pass   │
│ 2 │ require-tech-lead-label │ check-for-tech-lead │ tech-lead/Pod/valid-tech-lead-demo │ Pass   │
│ 3 │ valid-image             │ valid-image         │ valid-image-demo/Pod/invalid-image │ Pass   │
│───│─────────────────────────│─────────────────────│────────────────────────────────────│────────│

Test Summary: 3 tests passed and 0 tests failed
```

# Pod Security Standards

Pod Security Standards define 3 different levels of security. The Kyverno Pod Security Standard policies are available [here](https://kyverno.io/policies/pod-security/).

## Privileged

Lets apply the restricted policy:

```bash
kubectl apply -f pod-security-standard/policies/pod-security-standard-restricted.yaml
```

The output should be:

```
k apply -f pod-security-standard/demo-pods/testing-restricted.yaml
Error from server: error when creating "pod-security-standard/demo-pods/testing-restricted.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

policy Pod/demo-pods/valid-tech-lead-demo for resource violations: 

podsecurity-subrule-restricted:
  restricted: |
    Validation rule 'restricted' failed. It violates PodSecurity "restricted:latest": ({Allowed:false ForbiddenReason:allowPrivilegeEscalation != false ForbiddenDetail:container "failing-demo" must set securityContext.allowPrivilegeEscalation=false})
    ({Allowed:false ForbiddenReason:unrestricted capabilities ForbiddenDetail:container "failing-demo" must set securityContext.capabilities.drop=["ALL"]})
    ({Allowed:false ForbiddenReason:runAsNonRoot != true ForbiddenDetail:pod or container "failing-demo" must set securityContext.runAsNonRoot=true})
    ({Allowed:false ForbiddenReason:seccompProfile ForbiddenDetail:pod or container "failing-demo" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost"})
require-labels:
  check-for-labels: 'validation error: The label `tech-lead` is required. rule check-for-labels
    failed at path /metadata/labels/tech-lead/'
```

Now lets test opting the pod out of the policy:

```bash
kubectl apply -f pod-security-standard/policies/pod-security-standard-restricted-opt-out.yaml
```

We should then be able to apply the previously failing pod:

```bash
k apply -f pod-security-standard/demo-pods/testing-restricted.yaml 
pod/valid-tech-lead-demo created
```

# Rapporting

First start cleaning up the previous demo:

```bash
k delete -f pod-security-standard/policies/pod-security-standard-restricted.yaml
k delete -f pod-security-standard/policies/pod-security-standard-restricted-opt-out.yaml
```

Add a pod that violates a future policy:

```bash
k apply -f pod-security-standard/demo-pods/testing-restricted.yaml
```

Now lets apply the policy:

```bash
k apply -f pod-security-standard/policies/pod-security-standard-restricted.yaml
```

You can now get a rapport

```bash
k get policyreports.wgpolicyk8s.io cpol-podsecurity-subrule-restricted -n demo-pods
NAME                                  PASS   FAIL   WARN   ERROR   SKIP   AGE
cpol-podsecurity-subrule-restricted   0      1      0      0       0      72s
```

# Mutate policy demo

In addition to validation, Kyverno can also mutate resources. For a full list of its features see [https://kyverno.io/docs/writing-policies/mutate/](https://kyverno.io/docs/writing-policies/mutate/) Lets apply a mutate policy:

```bash
k apply -f policies/mutate/set-image-pull-policy.yaml
```

Now add a pod that is missing imagePullPolicy:

```bash
k apply -f demo-pods/mutate/missing-imagePullPolicy.yaml
```
