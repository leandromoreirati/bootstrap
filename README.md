# Bootstrap
Basical bootstrap for configuration tools for a cloud and IaC.

## Use notes
This project is compatible with **Debian Like** instalations.

Performed the installation and configuration of [asdf](https://asdf-vm.com/#/core-manage-asdf).

The list of plugins to be installed is in the file list.txt, currently the following plugins are configured:

* [awscli](https://github.com/MetricMike/asdf-awscli)
* [consul](https://github.com/asdf-community/asdf-hashicorp)
* [dotnet-core](https://github.com/emersonsoares/asdf-dotnet-core)
* [gcloud](https://github.com/jthegedus/asdf-gcloud)
* [golang](https://github.com/kennyp/asdf-golang)
* [hadolint](https://github.com/looztra/asdf-hadolint)
* [helm](Helm)
* [helm-ct](https://github.com/tablexi/asdf-helm-ct)
* [istioctl](https://github.com/rafik8/asdf-istioctl)
* [jq](https://github.com/focused-labs/asdf-jq)
* [kops](https://github.com/Antiarchitect/asdf-kops)
* [kubectl](https://github.com/Banno/asdf-kubectl)
* [minikube](https://github.com/alvarobp/asdf-minikube)
* [minishift](https://github.com/sqtran/asdf-minishift)
* [oc](https://github.com/sqtran/asdf-oc)
* [packer](https://github.com/asdf-community/asdf-hashicorp)
* [python](https://github.com/danhper/asdf-python)
* [tekton-cli](https://github.com/johnhamelink/asdf-tekton-cli)
* [terraform](https://github.com/asdf-community/asdf-hashicorp)
* [terraform-docs](https://github.com/looztra/asdf-terraform-docs)
* [terraform-validator](https://github.com/looztra/asdf-terraform-validator)
* [terragrunt](https://github.com/lotia/asdf-terragrunt)
* [tflint](https://github.com/skyzyx/asdf-tflint)
* [tfsec](https://github.com/woneill/asdf-tfsec)
* [vagrant](https://github.com/asdf-community/asdf-hashicorp)
* [vault](https://github.com/asdf-community/asdf-hashicorp)

To add new plugins, just add the **list_plugin.txt** file, according to the standard:
column 1: Plugin name
column 2: plugin installation url (optional field)
column 3: version (optional field)

Column 1, plugin name is mandatory, columns 2 and 3 are optional.

Complete list of available [plugins](https://github.com/asdf-vm/asdf-plugins).

**Example:**

**terraform|https://github.com/Banno/asdf-hashicorp.git|0.12.20**

or

**terragrunt**

## Prerequistes
Before running the **bootstrap** script, we need to install and configure the following prerequisites:

* sudo
* [oh my zsh](https://ohmyz.sh/#install)

## 1. Instaling and configuring sudo

```bash
$ sudo apt-get update
$ sudo apt-get install sudo
```
 ### Configuring sudo
```bash
$ sudo visudo
%<GROUP> ALL=(root) NOPASSWD:ALL
```
### Create group
```bash
$ groupadd <GROUP>
```
### Add user to group
```bash
$ gpasswd -a $USER <GROUP>
```
## 2 . Install oh-my-zsh

```bash
$ sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
## Using the script

### Clone repo project
```bash
$ git clone git@github.com:leandromoreirati/bootstrap.git
```
### Runing Script
```bash
$ ./bootstrap.sh
```


