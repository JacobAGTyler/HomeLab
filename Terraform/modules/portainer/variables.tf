variable "cluster_issuer_name" {
  description = "cert-manager ClusterIssuer used for Portainer TLS certificate."
  type        = string
  default     = "letsencrypt-prod"
}

variable "portainer_image_tag" {
  description = "Portainer server image tag."
  type        = string
  default     = "2.39.0"
}

variable "agent_image_repository" {
  description = "Portainer agent image repository."
  type        = string
  default     = "portainer/agent"
}

variable "agent_image_tag" {
  description = "Portainer agent image tag. Keep aligned with Portainer server major/minor."
  type        = string
  default     = "2.39.0"
}

variable "agent_replicas" {
  description = "Replica count for the Portainer agent deployment."
  type        = number
  default     = 1
}

variable "agent_log_level" {
  description = "Log level for Portainer agent."
  type        = string
  default     = "INFO"
}

variable "agent_service_type" {
  description = "Kubernetes Service type for the Portainer agent service."
  type        = string
  default     = "LoadBalancer"
}

variable "agent_service_annotations" {
  description = "Annotations for the Portainer agent service."
  type        = map(string)
  default     = {}
}

variable "helm_timeout_seconds" {
  description = "Timeout in seconds for Portainer Helm operations."
  type        = number
  default     = 900
}

variable "load_balancer_ip" {
  description = "MetalLB IP to keep assigned to the Portainer service."
  type        = string
  default     = "10.3.0.101"
}

variable "service_ip_pool" {
  description = "MetalLB address pool annotation for the Portainer service."
  type        = string
  default     = "main-pool"
}
