variable "provider_config" {
  type = object({
    url             = string
    client_id_list  = list(string)
    thumbprint_list = list(string)
  })
  description = "OIDC provider details"
}