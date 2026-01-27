import models.io.upbound.platform.v1alpha1 as platformv1alpha1
import models.io.crossplane.helmm.v1beta1 as helmv1beta1


oxr = option("params").oxr # observed composite resource
_ocds = option("params").ocds # observed composed resources
_dxr = option("params").dxr # desired composite resource
dcds = option("params").dcds # desired composed resources

params = oxr.spec.parameters

_metadata = lambda name: str -> any {
    { annotations = { "krm.kcl.dev/composition-resource-name" = name }}
}

# spec defaults
_defaults = {
    managementPolicies = params.managementPolicies or ["*"]
    providerConfigRef = {
        kind = "ProviderConfig"
        name = params.providerConfigName
    }
}
 
_items = [
    helmv1beta1.Release {
        metadata = _metadata("helmRelease") | {
            labels = oxr.metadata.labels or {}
        }
        spec = _defaults | {
            forProvider = {
                chart = {
                    name = params.helm.chart.name
                    repository = params.helm.chart.repo
                    version = params.helm?.chart?.version or "25.0.4"
                }
                namespace = "ghost"
                set = [
                    {
                        name = "externalDatabase.host"
                        valueFrom = {
                            secretKeyRef = {
                                key = "host"
                                name = params.passwordSecretRef.name
                            }
                        }
                    }
                    {
                        name = "externalDatabase.user"
                        valueFrom = {
                            secretKeyRef = {
                                key = "username"
                                name = params.passwordSecretRef.name
                            }
                        }
                    }
                    {
                        name = "externalDatabase.password"
                        valueFrom = {
                            secretKeyRef = {
                                key = "password"
                                name = params.passwordSecretRef.name
                            }
                        }
                    }
                ]
                values = params.helm.values | {
                    image = {
                        registry = "docker.io"
                        repository = "bitnamilegacy/ghost"
                        tag = "6.0.5-debian-12-r0"
                        debug = True
                    }
                    volumePermissions = {
                        enabled = True
                        image = {
                            registry = "docker.io"
                            repository = "bitnamilegacy/os-shell"
                            tag = "12-debian-12-r51"
                        }
                    }
                    service = {
                        type = "LoadBalancer"
                    }
                    persistence = {
                        size = "10Gi"
                    }
                    mysql = {
                        enabled = False
                    }
                    externalDatabase = {
                        port = 3306
                        database = "upbound"
                        ssl = True
                    }
                    extraEnvVars = [
                        {
                            name = "database__connection__ssl__rejectUnauthorized"
                            value = "false"
                        }
                    ]
                    ghostBlogTitle = "Upbound Rocks!"
                    ghostHost = "upboundrocks.cloud"
                }
                wait = params.helm.wait
            }
            rollbackLimit = 3
        }
    }
]
items = _items
