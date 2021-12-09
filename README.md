** Install

# ensure myproject is created first
$ WATCH_NAMESPACE=myproject make install run

** Install in cluster (deployment):

Edit image, see this diff: t.ly/lafi

Generate image and install in cluster, notice 'deploy' Makefile target:

# I think the namespace must be set first: $ ksns myproject
$ IMAGE_TAG_BASE=docker.io/rauherna/memcached-operator VERSION=0.0.2 make docker-build docker-push deploy

** Install in cluster (bundle):

# I think the namespace must be set first: ksns myproject
# do not add the suffix '-bundle', it will be automatically generated for you
# when executing the command below
$ IMAGE_TAG_BASE=docker.io/rauherna/memcached-operator VERSION=0.0.2 make bundle bundle-build bundle-push
# enter namespace myproject before
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
