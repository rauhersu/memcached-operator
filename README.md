Notes based on the course: https://sdk.operatorframework.io/docs/building-operators/golang/tutorial/

# Generation of GVK, /api, /config and /controllers
$ operator-sdk init --domain example.com --repo github.com/example/memcached-operator
$ operator-sdk create api --group cache --version v1alpha1 --kind Memcached --resource --controller

# make generate generates code, like runtime.Object/DeepCopy implementations 
# (See XXXdeepcopy.go)
$ make generate

# make manifests generates Kubernetes object YAML, like CustomResourceDefinitions,
# WebhookConfigurations, and RBAC roles (See config/crd/bases/XXX.yaml)
$ make manifests

** Install out of cluster (standalone go program)

# ensure myproject is created first
# notice target install installs the CRD first
$ WATCH_NAMESPACE=myproject make install run
# CR edited to trigger reconciliation, see: https://t.ly/hrE6
$ k apply -f ~/gorepo/memcached-operator/config/samples/cache_v1alpha1_memcached.yaml

** Install in cluster (deployment):

Edit image, see this diff: t.ly/lafi

Generate image and install in cluster, notice 'deploy' Makefile target:

# I think the namespace must be set first: $ ksns myproject
# Notice docker-* only builds and pushes the image according to according to
# 'bundle.Dockerfile', the 'deploy' target actually deploys the image in the
# cluster
$ IMAGE_TAG_BASE=docker.io/rauherna/memcached-operator VERSION=0.0.2 make docker-build docker-push deploy

** Install in cluster (bundle):

# I think the namespace must be set first: ksns myproject
# do not add the suffix '-bundle', it will be automatically generated for you
# when executing the command below
$ IMAGE_TAG_BASE=docker.io/rauherna/memcached-operator VERSION=0.0.2 make bundle bundle-build bundle-push
# enter namespace myproject before
$ operator-sdk olm install
$ operator-sdk run bundle docker.io/rauherna/memcached-operator-bundle:v0.0.2

$ k get pods -A
NAMESPACE     NAME                                READY   STATUS    RESTARTS        AGE
...
olm           catalog-operator-84976fd7df-kx7fc   1/1     Running   0               37m
olm           olm-operator-844b4b88f8-t8lpt       1/1     Running   0               37m
olm           operatorhubio-catalog-j6tfr         1/1     Running   0               37m
olm           packageserver-7f94f8f59d-p587c      1/1     Running   0               37m
olm           packageserver-7f94f8f59d-zpw4s      1/1     Running   0               37m

# CR edited to trigger reconciliation, see: https://t.ly/hrE6
$ k apply -f ~/gorepo/memcached-operator/config/samples/cache_v1alpha1_memcached.yaml
$ k get pods -A
NAMESPACE     NAME                                                              READY   STATUS      RESTARTS        AGE
...
myproject     7691e7c0d16e5b2ecd803595225b2d59f64c8fe6e111f32d73708c--1-4h99p   0/1     Completed   0               10m
myproject     docker-io-rauherna-memcached-operator-bundle-v0-0-2               1/1     Running     0               10m
myproject     memcached-operator-controller-manager-c5dbc6d8f-zf8qs             2/2     Running     0               10m
myproject     memcached-sample-6c765df685-bsfrd                                 1/1     Running     0               7m38s
myproject     memcached-sample-6c765df685-cnhcv                                 1/1     Running     0               7m38s
myproject     memcached-sample-6c765df685-gnz57                                 1/1     Running     0               7m38s
olm           catalog-operator-84976fd7df-kx7fc                                 1/1     Running     0               48m
olm           olm-operator-844b4b88f8-t8lpt                                     1/1     Running     0               48m
olm           operatorhubio-catalog-j6tfr                                       1/1     Running     0               48m
olm           packageserver-7f94f8f59d-p587c                                    1/1     Running     0               48m
olm           packageserver-7f94f8f59d-zpw4s                                    1/1     Running     0               48m

** CR updates

Just do it through a patch:
$ kubectl patch memcached memcached-sample -p '{"spec":{"size": 5}}' --type=merge

** Cleanup

* Out of cluster

# deletes the CR
$ kubectl delete -f config/samples/cache_v1alpha1_memcached.yaml
# deletes the CRD
$ make uninstall

* In cluster

# deletes the CR
$ kubectl delete -f config/samples/cache_v1alpha1_memcached.yaml
# deletes the CRD
$ make uninstall
# deletes the controller
$ make undeploy
