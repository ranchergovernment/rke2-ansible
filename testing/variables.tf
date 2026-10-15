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
#  rocky9
#  rocky10
#  slem6
#  sles16
#  ubuntu22
#  ubuntu24
variable "os" {
  type        = string
  description = "AWS AMI OS"
  default     = "rocky9"
}

variable "amis" {
  description = "List of AMIs based on regions"
  type = map(map(object({
    ami  = string
    user = string
  })))
  default = {
    "us-east-2" = {
# Documentation: https://www.suse.com/suse-rke2/support-matrix/all-supported-versions/rke2-v1-35/
# We can safely remove Rocky 8 from testing because the default channel 'stable' is RKE2 v1.36+
# Official support for RHEL/Rocky/Amazon Linux 8 ended with RKE2 v1.35
# We can leave this in the event we need to test an older version of RKE2
#      "rocky8" = {
#        ami  = "ami-02391db2758465a87"
#        user = "rocky"
#      }
      "rocky9" = {
        ami  = "ami-05150ea4d8a533099"
        user = "rocky"
      }
      "rocky10" = {
        ami  = "ami-03582dd0dbc98678a"
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
      "sles16" = {
        ami  = "ami-04c81635606c22655"
        user = "sles"
      }
      "slem6" = {
        # SLE Micro 6.1
        # 6.2 is not yet available on AWS as of 10/15/2026
        ami  = "ami-0f835133e57750b8f"
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
