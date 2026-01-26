import models.io.crossplane.helmm.v1beta1 as helmv1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.platform.v1alpha1 as platformv1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "app"
        spec= {
            assertResources: [
                platformv1alpha1.App{
                    metadata = {
                        name = "configuration-app"
                        namespace = "default"
                    }
                    spec = {
                        parameters = {
                            helm = {
                                wait = False
                            }
                            passwordSecretRef = {
                                name = "configuration-app-mariadb"
                                namespace = "default"
                            }
                            providerConfigName = "uptest"
                        }
                    }
                }
                helmv1beta1.Release{
                    metadata = {
                        annotations = {
                            "crossplane.io/composition-resource-name" = "helmRelease"
                        }
                        ownerReferences = [
                            {
                                apiVersion = "platform.upbound.io/v1alpha1"
                                blockOwnerDeletion = True
                                controller = True
                                kind = "App"
                                name = "configuration-app"
                                uid = ""
                            }
                        ]
                    }
                    spec = {
                        managementPolicies = ["*"]
                        forProvider = {
                            chart = {
                                name = "ghost"
                                repository = "oci://registry-1.docker.io/bitnamicharts"
                                version = "25.0.4"
                            }
                            namespace = "ghost"
                            set = [
                                {
                                    name = "externalDatabase.host"
                                    valueFrom = {
                                        secretKeyRef = {
                                            key = "host"
                                            name = "configuration-app-mariadb"
                                        }
                                    }
                                }
                                {
                                    name = "externalDatabase.user"
                                    valueFrom = {
                                        secretKeyRef = {
                                            key = "username"
                                            name = "configuration-app-mariadb"
                                        }
                                    }
                                }
                                {
                                    name = "externalDatabase.password"
                                    valueFrom = {
                                        secretKeyRef = {
                                            key = "password"
                                            name = "configuration-app-mariadb"
                                        }
                                    }
                                }
                            ]
                            values = {
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
                            wait = False
                        }
                        providerConfigRef = {
                            kind = "ProviderConfig"
                            name = "uptest"
                        }
                        rollbackLimit = 3
                    }
                }
            ]
            compositionPath: "apis/apps/composition.yaml"
            xrPath: "examples/app/app-xr.yaml"
            xrdPath: "apis/apps/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items
