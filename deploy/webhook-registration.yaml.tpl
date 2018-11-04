---
apiVersion: admissionregistration.k8s.io/v1beta1
kind: MutatingWebhookConfiguration
metadata:
  name: in-toto-webhook
  labels:
    app: in-toto-webhook
    kind: validator
webhooks:
  - name: pod.admission.intoto.io
    clientConfig:
      service:
        name: in-toto-webhook
        namespace: in-toto
        path: "/pod"
      caBundle: CA_BUNDLE
    rules:
      - operations:
        - CREATE
        - UPDATE
        apiGroups:
        - ""
        apiVersions:
        - v1
        resources:
        - pods
    failurePolicy: Fail
    namespaceSelector:
      matchLabels:
        in-toto-validation: enabled
  - name: deployment.admission.intoto.io
    clientConfig:
      service:
        name: in-toto-webhook
        namespace: in-toto
        path: "/deployment"
      caBundle: CA_BUNDLE
    rules:
      - operations:
        - CREATE
        - UPDATE
        apiGroups:
        - apps
        - extensions
        apiVersions:
        - "*"
        resources:
        - deployments
    failurePolicy: Fail
    namespaceSelector:
      matchLabels:
        in-toto-validation: enabled
  - name: daemonset.admission.intoto.io
    clientConfig:
      service:
        name: in-toto-webhook
        namespace: in-toto
        path: "/daemonset"
      caBundle: CA_BUNDLE
    rules:
      - operations:
        - CREATE
        - UPDATE
        apiGroups:
        - apps
        - extensions
        apiVersions:
        - "*"
        resources:
        - daemonsets
    failurePolicy: Fail
    namespaceSelector:
      matchLabels:
        in-toto-validation: enabled
  - name: statefulset.admission.intoto.io
    clientConfig:
      service:
        name: in-toto-webhook
        namespace: in-toto
        path: "/statefulset"
      caBundle: CA_BUNDLE
    rules:
      - operations:
        - CREATE
        apiGroups:
        - apps
        apiVersions:
        - "*"
        resources:
        - statefulsets
    failurePolicy: Fail
    namespaceSelector:
      matchLabels:
        in-toto-validation: enabled
