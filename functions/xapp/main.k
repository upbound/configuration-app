import models.io.upbound.platform.v1alpha1 as platformv1alpha1
import models.io.crossplane.helm.v1beta1 as helmv1beta1


oxr = platformv1alpha1.XApp{**option("params").oxr}

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

schema DefaultSpec:
    deletionPolicy: str
    providerConfigRef: {str:str}
    forProvider: {str:str}

# spec defaults
_defaultSpec = DefaultSpec {
    deletionPolicy = oxr.spec.parameters.deletionPolicy or "Delete"
    providerConfigRef = {
        name = oxr.spec.parameters.providerConfigName or "default"
    }
    forProvider = {}
}

_items = [
    helmv1beta1.Release{
        metadata = {
            labels = oxr.metadata.labels
            annotations = oxr.metadata.annotations
        } | _metadata("helmRelease")
        spec = {
            **_defaultSpec
            forProvider = {
                chart = {
                    name = "ghost"
                    repository = "https://charts.bitnami.com/bitnami"
                    version = oxr.spec.parameters.helm?.chart?.version or "19.3.10"
                }
                namespace = "ghost"
                set = [
                    {
                        name = "externalDatabase.host"
                        valueFrom = {
                            secretKeyRef = {
                                key = "host"
                                name = oxr.spec.parameters.passwordSecretRef.name
                                namespace = oxr.spec.parameters.passwordSecretRef.namespace
                            }
                        }
                    }
                    {
                        name = "externalDatabase.user"
                        valueFrom = {
                            secretKeyRef = {
                                key = "username"
                                name = oxr.spec.parameters.passwordSecretRef.name
                                namespace = oxr.spec.parameters.passwordSecretRef.namespace
                            }
                        }
                    }
                    {
                        name = "externalDatabase.password"
                        valueFrom = {
                            secretKeyRef = {
                                key = "password"
                                name = oxr.spec.parameters.passwordSecretRef.name
                                namespace = oxr.spec.parameters.passwordSecretRef.namespace
                            }
                        }
                    }
                ]
                values = {
                    **oxr.spec.parameters.helm.values
                    externalDatabase = {
                      database = "upbound"
                      port =  3306
                    }
                    ghostBlogTitle = "Upbound Rocks!"
                    ghostHost = "upboundrocks.cloud"
                    mysql = {
                      enabled = False
                    }
                    persistence = {
                      enabled = False
                    }
                }
                wait = oxr.spec.parameters.helm.wait
            }
            rollbackLimit = 3
        }
    }
]
items = _items
