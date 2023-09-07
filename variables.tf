variable "project" {
  default     = "practicegcp-396109"
}

variable "region" {
  default     = "us-central1"
}

variable "zone" {
  default     = "us-central1-a"
}

variable "subnet_ip_cidr" {
  default     = "10.0.1.0/24"
}

variable "machine-type" {
  default = "e2-medium"
}

variable "source-image" {
  default = "ubuntu-2004-lts"
}

variable "port" {
  default = "80"
}

variable "max_replicas" {
  default = "3"
}

variable "min_replicas" {
  default = "2"
}

variable "cooldown_period" {
  default = "60"
}

variable "check_interval_sec" {
  default = "5"
}

variable "timeout_sec" {
  default = "5"
}

variable "healthy_threshold" {
  default = "2"
}

variable "unhealthy_threshold" {
  default = "4"
}

