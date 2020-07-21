#
# Variables Configuration
#

variable "awsregion" {
  description = "Desired AWS region. By the time of this writing us-west-1 doesn't support EKS."
  default = "us-west-2"
  type = string
}


variable "awscredentials" {
  description = "Path to AWS credentials file."
  default = "~/.aws/credentials"
  type = string
}


variable "awsprofile" {
  description = "AWS credentials profile name."
  default = "notdefault"
  type = string
}


variable "domain" {
  description = "Route53 zone name."
  default = "example.org"
  type = string
}


variable "domain_id" {
  description = "Route53 domain ID code"
  default = "Z01792AAAAAAAAAABBCC1."
  type = string
}


variable "cluster-name" {
  description = "Cluster name."
  default = "mycluster"
  type = string
}


variable "cluster-version" {
  description = "Cluster version. By the time of this writing there were some helm charts that rely on certain APIs deprecated from 1.16 and later versions of Kubernetes."
  default = "1.15"
  type = string
}


variable "node-types" {
  description = "This is a list where you define what kind of machines you want in your worker node groups."
  default = ["t3.small"]
  type = list
}


variable "nodes-desired" {
  description = "How many nodes you want to be the default state of your cluster."
  default = 2
  type = number
}


variable "nodes-min" {
  description = "What is the minimum number of nodes you want to be running in your cluster."
  default = 1
  type = number
}


variable "nodes-max" {
  description = "What is the maximum number of nodes you want to alocate to your cluster in case you need more capacity."
  default = 4
  type = number
}


variable "ssh-key-name" {
  description = "SSH key name. Note that the worker nodes are alocated in a private network so you might need to install a bastion host to access those nodes."
  default = "deployer"
  type = string
}


variable "ssh-public-key" {
  description = "Your public SSH key."
  default = "ssh-rsa AAAAB...Z=="
  type = string
} 


variable "enable-kubedashboard" {
  description = "Do you want to enable Kubernetes Dashboard? Note: there might be extra configuration needed to access with AWS IAM credentials."
  default = true
  type = bool
}


variable "enable-autoscaler" {
  description = "Do you want to enable Cluster Autoscaler?"
  default = true
  type = bool
}


variable "enable-cloudwatch" {
  description = "Do you want to enable Fluentd Cloudwatch?"
  default = true
  type = bool
}


variable "cloudwatch-retention" {
  description = "What is the desired retention period in days for those logs?"
  default = 180
  type = number
}


variable "enable-externaldns" {
  description = "Do you want to enable external-dns?"
  default = true
  type = bool
}


variable "enable-certmanager" {
  description = "Do you want to enable cert-manager?"
  default = true
  type = bool
}


variable "enable-nginxingress" {
  description = "Do you want to enable the Nginx Ingress Controller?"
  default = true
  type = bool
}
