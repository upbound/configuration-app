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
        metadata = _metadata("helmRelease")
        spec = _defaults | {
            forProvider = {
                chart = {
                    name = params.helm.chart.name
                    repository = params.helm.chart.repo
                    version = params.helm?.chart?.version or "23.0.25"
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
                    global.security.allowInsecureImages = True
                    image = {
                        repository = "bitnamilegacy/ghost"
                    }
                }
                wait = params.helm.wait
            }
            rollbackLimit = 3
        }
    }
]
items = _items
