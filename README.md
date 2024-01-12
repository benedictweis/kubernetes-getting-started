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
- Optional: [gnu-make](https://www.gnu.org/software/make/) for using the provided [Makefile](https://github.com/benedictweis/kubernetes-getting-started/blob/main/Makefile)

## 🏁 Introduction

Examine the two folders [backend](https://github.com/benedictweis/kubernetes-getting-started/tree/main/backend) and [frontend](https://github.com/benedictweis/kubernetes-getting-started/tree/main/frontend).

[backend](https://github.com/benedictweis/kubernetes-getting-started/tree/main/backend) contains a nodejs application that exposes a `/hello` endpoint. The endpoint returns a random word from a predefined list each time it is called.

[frontend](https://github.com/benedictweis/kubernetes-getting-started/tree/main/frontend) also contains a nodejs application that serves a website where a random word from [backend](https://github.com/benedictweis/kubernetes-getting-started/tree/main/backend) is presented to the user.

A user request will be handled as follows:

![architecture diagram](https://github.com/benedictweis/kubernetes-getting-started/blob/main/architecture.drawio.png)

## What is kubernetes?

Kubernetes is a container orchestrator. It manages communication between containers, scaling containers, dns, container lifecycle and much more. Kubernetes itself is made up of many smaller components although when talking about "the kubernetes way", kubernetes is more commonly associated with a set of principles that it is with a piece of software. Kubernetes is mostly used to deploy a containerized microservices architecture. It is itself very flexible an can be adapted to face almost all system deployment challenges.

### Kubernetes Components

The biggest unit in kubernetes is the cluster. A cluster is made up of a collection of nodes (that are basically just worker machines). A node hosts a collection of pods which again are a collection of associated containers, although it is rather common that a pod only contains a single container. This container can be compared to a familiar docker container.

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

We will be using an adapted version of this exact command later in this guide.