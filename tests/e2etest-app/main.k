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
                                name = "configuration-aws-database-mariadb"
                            }
                            providerConfigName = "configuration-app"
                        }
                    }
                }
            ]
            extraResources: [
                {
                    apiVersion = "pkg.crossplane.io/v1"
                    kind = "Configuration"
                    metadata = {
                        name = "configuration-aws-eks"
                    }
                    spec = {
                        package = "xpkg.upbound.io/upbound/configuration-aws-eks:v0.17.0"
                    }
                }
                {
                    apiVersion = "pkg.crossplane.io/v1"
                    kind = "Configuration"
                    metadata = {
                        name = "configuration-aws-network"
                    }
                    spec = {
                        package = "xpkg.upbound.io/upbound/configuration-aws-network:v0.24.0"
                    }
                }
                {
                    apiVersion = "pkg.crossplane.io/v1"
                    kind = "Configuration"
                    metadata = {
                        name = "configuration-aws-database"
                    }
                    spec = {
                        package = "xpkg.upbound.io/upbound/configuration-aws-database:v0.16.0"
                    }
                }
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "XSQLInstance"
                    metadata = {
                        name = "configuration-aws-database-mariadb"
                    }
                    spec = {
                        parameters = {
                            region = "us-west-2"
                            engine = "mariadb"
                            engineVersion = "10.11.6"
                            storageGB = 5
                            autoGeneratePassword = True
                            passwordSecretRef = {
                                namespace = "default"
                                name = "mariadbsecret"
                                key = "password"
                            }
                            networkRef = {
                                id = "configuration-app"
                            }
                        }
                        writeConnectionSecretToRef = {
                            name = "configuration-aws-database-mariadb"
                            namespace = "default"
                        }
                    }
                }
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "XEKS"
                    metadata = {
                        name = "configuration-aws-eks"
                    }
                    spec = {
                        parameters = {
                            id = "configuration-app"
                            region = "us-west-2"
                            version = "1.27"
                            nodes = {
                                count = 1
                                instanceType = "t3.small"
                            }
                        }
                        writeConnectionSecretToRef = {
                            name = "configuration-aws-eks-kubeconfig"
                            namespace = "upbound-system"
                        }
                    }
                }
                {
                    apiVersion = "aws.platform.upbound.io/v1alpha1"
                    kind = "XNetwork"
                    metadata = {
                        name = "configuration-aws-network"
                    }
                    spec = {
                        parameters = {
                            id = "configuration-app"
                            region = "us-west-2"
                        }
                    }
                }
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
