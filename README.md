# SIMPLE EKS CLUSTER SETUP

This repo contains a reference to provision an eks cluster via eksctl.  
Included is an extras section to bootstrap CI and CD components into the cluster along with  ingress.

**Background:**

This is **_Part 1_** of a cluster setup 
see the bellow repos for next steps:

* [Part 1 setting up EKS ](https://github.com/bbdsoftware/eks-bootstrap)
* [Part 2 setting up CI](https://github.com/bbdsoftware/eks-jenkins-ci)
* [Part 3 setting up CD ](https://github.com/bbdsoftware/eks-argo-cd)

**Service example:**
An example spring boot service can be found here.  [demo](https://github.com/bbdsoftware/eks-pring-boot-jenkinsop-example) 
This is referenced in all parts as a demo service

**In use:**
* [helm](https://helm.sh/)
* [argocd](https://argoproj.github.io/argo-cd/)
* [Jenkins operator](https://jenkinsci.github.io/kubernetes-operator/)
* [eksctl fro EKS](https://eksctl.io)



**Reference articles and videos:**
* https://www.twistlock.com/2018/08/06/gitops-101-gitops-use/
* https://www.weave.works/blog/what-is-gitops-really
* https://jenkins.io/doc/book/pipeline/
* https://www.youtube.com/watch?v=4owbdHzfyMY
* https://blog.argoproj.io/introducing-argo-cd-declarative-continuous-delivery-for-kubernetes-da2a73a780cd
* https://eksctl.io
* https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html



---
**NOTE**

Once this is completed please see  [Part 2 setting up CI](https://github.com/bbdsoftware/eks-jenkins-ci) for setting up ci based on jenkins operator

---


## Creating  EKS cluster 
The folder *eksctl* contains a reference eks cluster yaml definition  to provision a cluster on aws

Run

```eksctl create cluster -f eksctl/eksctl-cluster```

References :
* https://github.com/weaveworks/eksctl
* https://eksctl.io
* https://eksctl.io/usage/creating-and-managing-clusters/   


## Extras

### Ingress
---

![INgress](./extras/ingress/ingress.jpg)

**`Info`**
The ingress folder contains a *setupingress.sh* script.The script assumes you have helm installed and configured 
The set up leverages the use of aws alb ingress controller and nginx ingress controller.  
One alb targeted ingress is created for the nginx-controller. 
This will effectively create one alb ingress on AWS ingress all traffic to the nginx-ingress controller. 
After this all workloads deployed to the cluster can target the nginx ingress type  ie ``` kubernetes.io/ingress.class: nginx``` as this will be the base controller used for ingress.




**_Steps:**_  
* You will need to provide the cluster vpc to the [values-alb-ingress.yaml ](https://github.com/bbdsoftware/eks-bootstrap/extras/ingress/values-alb-ingress.yaml) 
    ```clusterName: ql-dev-stage
    awsRegion: eu-west-1
    awsVpcID: "TOBEREPLACED"
    rbac:
    create: true
    serviceAccountName: alb-ingress
     ```
* You will need to provide the R53 domain and zoneid to the [values-eternal-dns.yaml ](https://github.com/bbdsoftware/eks-bootstrap/extras/ingress/values-eternal-dns.yaml) 
    ```
    ....
        domainFilters: [TOBEREPLACED]
        zoneIdFilters: [TOBEREPLACED]

     ```
     ```
* You will need to provide your cert arn  [alb-nginx-controller ](https://github.com/bbdsoftware/eks-bootstrap/extras/ingress/alb-nginx-controller) 
    ```
    ....
            name: ql-alb-nginx
            namespace: ingress-system
            annotations:
                alb.ingress.kubernetes.io/healthcheck-path: /
                alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80,"HTTPS": 443}]'
                alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
                alb.ingress.kubernetes.io/certificate-arn: [YOURCERTARN]
    ....            
     ```     
* Run script   [setupingress.sh](https://github.com/bbdsoftware/eks-bootstrap/extras/ingress/setupingress.sh)  
  ```
  sh  extras/setupingress.sh 
  ```


### CI
---
The ci folder has the set up to deploy the jenkins-operator into the cluster.        
This is used to leverage jenkins as a CI tool to enable ci within the the kubernetes cluster

* Run script   [setupingress.sh](https://github.com/bbdsoftware/eks-bootstrap/extras/ci/setupci.sh)  
  ```
  sh  /extras/ci/setupci.sh 
  ```
Please see https://github.com/kanzifucius/spring-boot-k8s-jenkinsop-example for an example spring boot applciation building   using the jenkins operator


References :
* https://jenkinsci.github.io/kubernetes-operator/
* https://github.com/jenkinsci/kubernetes-operator

### CD (GITOPS)
---
The cd folder has the set up to deploy argo-cd into the cluster.        
Argo cd is used as a gitops tool to facilitate CD using gitops principals

steps:

* Supply your domain in the argo ingress manifest   [./extras/cd/argo/ingress.yaml](https://github.com/bbdsoftware/eks-bootstrap/tree/master/extras/cd/argo/ingress.yaml)  
  ```
    ....
    spec:
    rules:
        - host: argogrpc.YOURDOMIAN.com
        http:
            paths:
            - backend:
                serviceName: argocd-server
                servicePort: https
    ....
    rules:
        - host: argo.YOURDOMIAN.com
        http:
            paths:
            - backend:
                serviceName: argocd-server
                servicePort: https

  ```
* Run script   [setupcd.sh](https://github.com/bbdsoftware/eks-bootstrap/tree/master/extras/cd/argo/setupcd.sh)  
  ```
  sh  /extras/cd/argo/setupcd.sh 
  ```
Please see [demo](https://github.com/bbdsoftware/eks-pring-boot-jenkinsop-example) for an example spring boot application building   using the jenkins via the jenkins operator


References :
* https://argoproj.github.io/argo-cd/




### CLUSTER LOGGING
---

The logging folder has the set up to deploy fluentd-cloudwatch  into the cluster.        
You will need to create a log group or supply an exiting log group in Cloudwatch and update the values-logging.yaml accordingly

NOTE  nthe worker nodes role will need a policy to be able to write and access cloud watch eg


k8s-logs-policy
```
    {
    "Version": "2012-10-17",
        "Statement": [
                {
                "Sid": "logs",
                "Effect": "Allow",
                "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
                ],
                "Resource": [
                "arn:aws:logs:*:*:*"
                ]
            }
        ]
    }
```

NOTE 

```
...
awsRegion: eu-west-1
awsRole:
awsAccessKeyId:
awsSecretAccessKey:
logGroupName:  /aws/eks/YOURCLUSTER/containers
....
```

# TODO
* Make this repo in an app of apps pattern to be deployed with argo cd  ref https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/
* Include the prometheus operator
* Include the grafana operator