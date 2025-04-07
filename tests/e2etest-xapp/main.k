import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.platform.v1alpha1 as platformv1alpha1

_items = [
    metav1alpha1.E2ETest{
        metadata.name: "xapp"
        spec= {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
                platformv1alpha1.XApp{
                    metadata = {
                        name = "configuration-app"
                    }
                    spec = {
                        parameters = {
                            helm = {
                                wait = False
                            }
                            passwordSecretRef = {
                                namespace = "default"
                                name = "configuration-aws-database-mariadb"
                            }
                            providerConfigName = "configuration-app"
                        }
                        writeConnectionSecretToRef = {
                            name = "configuration-app"
                            namespace = "default"
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
                    apiVersion = "aws.upbound.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata.name = "default"
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
