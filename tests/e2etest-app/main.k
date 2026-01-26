import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.platform.v1alpha1 as platformv1alpha1

_items = [
    metav1alpha1.E2ETest{
        metadata.name: "app"
        spec= {
            crossplane = {
                version = "2.0.2-up.5"
                autoUpgrade.channel = "None"
            }
            defaultConditions: ["Ready"]
            manifests: [
                platformv1alpha1.App{
                    metadata = {
                        name = "configuration-app"
                        namespace = "default"
                    }
                    spec = {
                        parameters = {
                            helm = {
                                chart = {
                                    name = "ghost"
                                    repo = "oci://registry-1.docker.io/bitnamicharts"
                                    version = "25.0.4"
                                }
                                wait = False
                            }
                            passwordSecretRef = {
                                namespace = "default"
                                name = "configuration-aws-database-mariadb-sql"
                            }
                            providerConfigName = "configuration-app"
                        }
                    }
                }
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "SQLInstance"
                    metadata = {
                        name = "configuration-aws-database-mariadb"
                        namespace = "default"
                    }
                    spec = {
                        parameters = {
                            region = "us-west-2"
                            engine = "mariadb"
                            engineVersion = "11.8.3"
                            storageGB = 5
                            autoGeneratePassword = True
                            passwordSecretRef = {
                                name = "mariadbsecret"
                                key = "password"
                            }
                            networkRef = {
                                id = "configuration-app"
                            }
                        }
                    }
                }
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "EKS"
                    metadata = {
                        name = "configuration-aws-eks"
                        namespace = "default"
                    }
                    spec = {
                        parameters = {
                            id = "configuration-app"
                            region = "us-west-2"
                            version = "1.34"
                            nodes = {
                                count = 1
                                instanceType = "t3.small"
                            }
                        }
                    }
                }
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "Network"
                    metadata = {
                        name = "configuration-aws-network"
                        namespace = "default"
                    }
                    spec = {
                        parameters = {
                            id = "configuration-app"
                            region = "us-west-2"
                        }
                    }
                }
            ]
            initResources: [
                {
                    apiVersion = "pkg.crossplane.io/v1"
                    kind = "Configuration"
                    metadata = {
                        name = "configuration-aws-eks"
                    }
                    spec = {
                        package = "xpkg.upbound.io/upbound/configuration-aws-eks:v2.0.0"
                    }
                }
                {
                    apiVersion = "pkg.crossplane.io/v1"
                    kind = "Configuration"
                    metadata = {
                        name = "configuration-aws-network"
                    }
                    spec = {
                        package = "xpkg.upbound.io/upbound/configuration-aws-network:v2.0.0"
                    }
                }
                {
                    apiVersion = "pkg.crossplane.io/v1"
                    kind = "Configuration"
                    metadata = {
                        name = "configuration-aws-database"
                    }
                    spec = {
                        package = "xpkg.upbound.io/upbound/configuration-aws-database:v2.0.0"
                    }
                }
                {
                    apiVersion: "pkg.crossplane.io/v1"
                    kind: "Provider"
                    metadata.name: "upbound-provider-family-aws"
                    spec.package: "xpkg.upbound.io/upbound/provider-family-aws:v2.3.0"
                }
            ]
            extraResources: [
                {
                    apiVersion = "aws.m.upbound.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata = {
                        name = "default"
                        namespace = "default"
                    }
                    spec = {
                        credentials = {
                            source = "Upbound"
                            upbound = {
                                webIdentity = {
                                    roleARN = "arn:aws:iam::609897127049:role/solutions-e2e-provider-aws"
                                }
                            }
                        }
                    }
                }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items= _items
