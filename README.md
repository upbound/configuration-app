# App Configuration

This repository contains an Upbound project, tailored for users establishing their initial control plane with [Upbound](https://cloud.upbound.io). This configuration deploys a fully managed Ghost blog application as an example of how to deploy apps.

## Overview

The core components of a custom API in [Upbound Project](https://docs.upbound.io/learn/control-plane-project/) include:

- **CompositeResourceDefinition (XRD):** Defines the API's structure.
- **Composition(s):** Configures the Functions Pipeline
- **Embedded Function(s):** Encapsulates the Composition logic and implementation within a self-contained, reusable unit

In this specific configuration, the API contains:

- **an [App](/apis/definition.yaml) custom resource type.**
- **Composition:** Configured in [/apis/xapps/composition.yaml](/apis/xapps/composition.yaml), it provisions a Ghost blog deployment with helm and resources.
- **Embedded Function:** The Composition logic is encapsulated within [embedded function](/functions/xapp/main.k)

## Deployment

- Execute `up project run`
- Alternatively, install the Configuration from the [Upbound Marketplace](https://marketplace.upbound.io/configurations/upbound/configuration-app)
- Check [examples](/examples/) for example XR(Composite Resource)

## Testing

The configuration can be tested using:

- `up composition render --xrd=apis/definition.yaml apis/xapps/composition.yaml examples/app-xr.yaml` to render the composition
- `up test run tests/*` to run composition tests in `tests/test-xapp/`
- `up test run tests/* --e2e` to run end-to-end tests in `tests/e2etest-xapp/`

## Next steps

This repository serves as a foundational step. To enhance the configuration, consider:

1. create new API definitions in this same repo
2. editing the existing API definition to your needs

To learn more about how to build APIs for your managed control planes in Upbound, read the guide on [Upbound's docs](https://docs.upbound.io/).