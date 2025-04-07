import models.io.crossplane.helm.v1beta1 as helmv1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.platform.v1alpha1 as platformv1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "xapp"
        spec= {
            assertResources: [
                platformv1alpha1.XApp{
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
                        writeConnectionSecretToRef = {
                            name = "configuration-app"
                            namespace = "default"
                        }
                    }
                }
                helmv1beta1.Release{
                    metadata = {
                        annotations = {
                            "crossplane.io/composition-resource-name" = "helmRelease"
                        }
                        generateName = "configuration-app-"
                        labels = {
                            "crossplane.io/composite" = "configuration-app"
                        }
                        ownerReferences = [
                            {
                                apiVersion = "platform.upbound.io/v1alpha1"
                                blockOwnerDeletion = True
                                controller = True
                                kind = "XApp"
                                name = "configuration-app"
                                uid = ""
                            }
                        ]
                    }
                    spec = {
                        forProvider = {
                            chart = {
                                name = "ghost"
                                repository = "https://charts.bitnami.com/bitnami"
                                version = "19.3.10"
                            }
                            namespace = "ghost"
                            set = [
                                {
                                    name = "externalDatabase.host"
                                    valueFrom = {
                                        secretKeyRef = {
                                            key = "host"
                                            name = "configuration-app-mariadb"
                                            namespace = "default"
                                        }
                                    }
                                }
                                {
                                    name = "externalDatabase.user"
                                    valueFrom = {
                                        secretKeyRef = {
                                            key = "username"
                                            name = "configuration-app-mariadb"
                                            namespace = "default"
                                        }
                                    }
                                }
                                {
                                    name = "externalDatabase.password"
                                    valueFrom = {
                                        secretKeyRef = {
                                            key = "password"
                                            name = "configuration-app-mariadb"
                                            namespace = "default"
                                        }
                                    }
                                }
                            ]
                            values = {
                                externalDatabase = {
                                    database = "upbound"
                                    port = 3306
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
                            wait = False
                        }
                        providerConfigRef = {
                            name = "uptest"
                        }
                        rollbackLimit = 3
                    }
                }
            ]
            compositionPath: "apis/composition.yaml"
            xrPath: "examples/app-xr.yaml"
            xrdPath: "apis/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items
