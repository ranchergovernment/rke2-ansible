variable "aws_region" {
  type        = string
  description = "AWS Region the instance is launched in"
  default     = "us-east-2"
}

variable "aws_subnet" {
  description = "List of vectors of subnets and Availability Zones"
  type        = string
  default     = "subnet-0e478ddd6ae2ed0b4"
}

variable "tf_user" {
  type    = string
  default = "rke2-ansible-github-actions"
}

### AMI
variable "instance_type" {
  type        = string
  description = "AWS type of instance"
  default     = "t2.xlarge"
}

# OS Options
#  rocky8
#  rocky9
variable "os" {
  type        = string
  description = "AWS AMI OS"
  default     = "rocky8"
}

variable "amis" {
  description = "List of AMIs based on regions"
  type = map(map(object({
    ami  = string
    user = string
  })))
  default = {
    "us-east-2" = {
      "rocky8" = {
        ami  = "ami-02391db2758465a87"
        user = "rocky"
      }
      "rocky9" = {
        ami  = "ami-05150ea4d8a533099"
        user = "rocky"
      }
      "ubuntu22" = {
        ami  = "ami-00eb69d236edcfaf8"
        user = "ubuntu"
      }
      "ubuntu24" = {
        ami  = "ami-036841078a4b68e14"
        user = "ubuntu"
      }
      "sles15" = {
        # WIP: This is SLES SP7. Needs testing...
        ami  = "ami-01de4781572fa1285"
        #        ami  = "ami-0371c70ae504994fd"
        user = "sles"
      }
      "slem6" = {
        # WIP: This AMI ID is valid but its not available without subscription. Working out a solution...
        ami  = "ami-01f988ce7e5a84929"
        user = "sles"
      }
    }
  }
}

variable "control_nodes" {
  type        = number
  description = "Number of RKE2 manager nodes"
  default     = 1
}

variable "worker_nodes" {
  type        = number
  description = "Number of RKE2 worker nodes"
  default     = 1
}

variable "extra_worker_nodes" {
  type        = number
  description = "Number of RKE2 worker nodes to add for idempotency tests"
  default     = 1
}

variable "ansible_user" {
  type        = string
  description = "Username used by Ansible to run remote configuration"
  default     = "ubuntu"
}

variable "GITHUB_RUN_ID" {}
