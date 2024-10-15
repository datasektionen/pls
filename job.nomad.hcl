job "pls" {
  type = "service"

  group "pls" {
    network {
      port "http" { }
    }

    service {
      name     = "pls"
      port     = "http"
      provider = "nomad"
      tags = [
        "traefik-external.enable=true",
        "traefik-external.http.routers.pls.rule=Host(`pls.datasektionen.se`)",
        "traefik-external.http.routers.pls.entrypoints=websecure",
        "traefik-external.http.routers.pls.tls.certresolver=default",

        "traefik-internal.enable=true",
        "traefik-internal.http.routers.pls.rule=Host(`pls.nomad.dsekt.internal`)",
      ]
    }

    task "pls" {
      driver = "docker"

      config {
        image = var.image_tag
        ports = ["http"]
      }

      template {
        data        = <<ENV
PORT={{ env "NOMAD_PORT_http" }}
{{ with nomadVar "nomad/jobs/pls" }}
DATABASE_URL=postgres://pls:{{ .database_password }}@postgres.dsekt.internal:5432/pls
LOGIN_API_KEY={{ .login_api_key }}
{{ end }}
LOGIN_API_URL=https://logout.datasektionen.se/legacyapi
LOGIN_FRONTEND_URL=https://logout.datasektionen.se/legacyapi
ENV
        destination = "local/.env"
        env         = true
      }
    }
  }
}

variable "image_tag" {
  type = string
  default = "ghcr.io/datasektionen/pls:latest"
}
