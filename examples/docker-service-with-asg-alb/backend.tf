terraform {
  backend "remote" {
    organization = "kolvin"

    workspaces {
      name = "github-actions"
    }
  }
}
