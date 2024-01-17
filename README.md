# ⛴️ kubernetes-getting-started

This is an example repository to introduce you to kubernetes.It covers core concepts and leaves you wit an solid foundation, from which you can build you own app or extend your kubernetes knowledge.

## Prerequisites

All of the shell commands mentioned in this document are meant to be run from the repository's root folder.

### Knowledge

- Basic knowledge of docker, mainly an understanding of images and containers
- Basic knowledge of web development

### Software

- [Docker](https://www.docker.com) for building images
- [kind](https://kind.sigs.k8s.io) for setting up a local cluster
- [kubectl](https://kubernetes.io/docs/reference/kubectl) for interacting with the cluster
- Optional: [k9s](https://k9scli.io) for easier troubleshooting and for viewing the cluster
- Optional: [gnu-make](https://www.gnu.org/software/make/) for using the provided [Makefile](./Makefile)

## 🏁 Introduction

Examine the two folders [backend](./backend/) and [frontend](./frontend/).

[backend](./backend/) contains a nodejs application that exposes a `/hello` endpoint. The endpoint returns a random word from a predefined list each time it is called.

[frontend](./frontend/) also contains a nodejs application that serves a website where a random word from [backend](./backend/) is presented to the user.

A user request will be handled as follows:

<img src="architecture.drawio.png" width=40% alt="architecture diagram">

## What is kubernetes?

Kubernetes is a container orchestrator. It manages communication between containers, scaling containers, dns, container lifecycle and much more. Kubernetes itself is made up of many smaller components although when talking about "the kubernetes way", kubernetes is more commonly associated with a set of principles that it is with a piece of software. Kubernetes is mostly used to deploy a containerized microservices architecture. It is itself very flexible an can be adapted to face almost all system deployment challenges.

### Kubernetes Components

The biggest unit in kubernetes is the cluster. A cluster is made up of a collection of nodes (which are basically just worker machines). A node hosts a collection of pods which again are a collection of associated containers, although it is rather common that a pod only contains a single container. This container can be compared to a familiar docker container.

## Obtaining a cluster

For development purposes, you are going to need a cluster. You can obtain a cluster in one of the following ways.

- From hyperscalers such as AWS, GCP, AKS, AliCloud etc.
  - this is usually very expensive but there is a list for [obtaining free trial clusters for a lot of different hyperscalers](https://github.com/learnk8s/free-kubernetes)
- From Kubernetes as a Service providers such as [Gardener](https://gardener.cloud) or [Rancher](https://www.rancher.com)
  - this is typically reserved for enterprise customers with high demands as these solutions scale out to hundreds, thousands or even tens of thousands of clusters
- Locally with
  - [Kind](https://kind.sigs.k8s.io)
  - [Minikube](https://minikube.sigs.k8s.io/docs/)

We will be using kind in this example.

Staring a local kubernetes cluster with kind is as simple as running:

```bash
kind create cluster
```

For this demo, we need to create a slightly more specialized cluster. Create one by running

```bash
kind create cluster --config kind-config.yaml
```

or by using the Makefile (`make create-kind-cluster`).

This creates a cluster with a name (`word-app-demo`) and a port forwarding configuration to access our application later in this guide.

## Deploying the application

To deploy the application, its services (ie. frontend and backend) have to be containerized first. Luckily, this example provides us with a Dockerfile for each component.

### Building the images

Issue

```bash
docker build -t word-app-frontend -f ./frontend/Dockerfile ./frontend
docker build -t word-app-service -f ./backend/Dockerfile ./backend
```

to build the images locally.

Next they have to be inserted into the kind cluster.

### Loading the images into the kind cluster

Issue

```bash
kind load docker-image word-app-frontend --name word-app-demo
kind load docker-image word-app-service --name word-app-demo
```

to load the images into the kind cluster.

### Retrieve kubeconfig

To interact with the kuberentes cluster via `kubectl` (and other similar tools). You need to retrive a so called `kubeconfig` from the cluster. It contains values such as the hostname of the cluster along with some keys for verifying authority when executing actions on the cluster.

Retrieving your kubeconfig is usually a process that is specifiy to your provider (see [Obtaining a cluster](#obtaining-a-cluster)). In our case, kind provides an easy way of retrieving your kubeconfig:

```bash
kind get kubeconfig --name word-app-demo > kind-kubeconfig.yaml
```

Feel free to take a look at the kubeconfig.

Finally, the `KUBECONFIG` environment variable has to be set to the retrieved kubeconfig, to let other tools know where to find your desired kubeconfig.

Do this with

```bash
export KUBECONFIG=$PWD/kind-kubeconfig.yaml
```

### Applying the deployment

There is only one step left, actually deploying the application. To do this, examine the files contained in [`./deployments/`](./deployments/). Focus on the [`./deployments/frontend.yaml`](./deployments/frontend.yaml) and [`./deployments/backend.yaml`](./deployments/backend.yaml) files. They will be explained later in this guide. For now we will simply apply these two files to our cluster.

```bash
kubectl apply -f ./deployments/frontend.yaml
kubectl apply -f ./deployments/backend.yaml
```

At this point you can visit [localhost:8080](http://localhost:8080) and examine the running application.

## Further learning

- Kubernetes Tutorial for Beginners [Link](https://youtu.be/X48VuDVv0do)
- Kubernetes Documentation [Link](https://kubernetes.io/docs/concepts/overview/)