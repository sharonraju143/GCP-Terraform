provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "demo_network" {
  name = "my-network-1"
}

resource "google_compute_subnetwork" "demo_subnet" {
  name          = "my-subnet-1"
  region        = var.region
  network       = google_compute_network.demo_network.name
  ip_cidr_range = var.subnet_ip_cidr
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.demo_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.demo_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-mysql" {
  name    = "allow-mysql"
  network = google_compute_network.demo_network.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance_template" "php-template" {
  name_prefix = "php-template-"
  machine_type = var.machine-type


  disk {
    source_image = var.source-image
    auto_delete  = true
  }


  metadata = {
    ssh-keys = "sharon_60494:${file("C:\\Users\\Sharon Raju Rudraraj\\.ssh\\gcp_ssh.pub")}"
  }


  metadata_startup_script = file("shell.sh")
  network_interface {
    subnetwork = google_compute_subnetwork.demo_subnet.name

    access_config {

    }
  }
}

resource "google_compute_instance_group" "my_instance_group" {
  name        = "my-instance-group"
  zone        = var.zone
}
resource "google_compute_instance_group_manager" "my_instance_group_manager" {
  name              = "my-instance-group-manager"
  base_instance_name = "my-instance"
  zone              = var.zone
  target_size       = 2

  version {
    instance_template = google_compute_instance_template.php-template.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.example_health_check.id
    initial_delay_sec = 60
  }

  named_port {
    name = "http"
    port = var.port
  }
}

resource "google_compute_autoscaler" "auto-scaler" {
  name   = "auto-scaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.my_instance_group_manager.name

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period
  }
}

resource "google_compute_health_check" "example_health_check" {
  name               = "example-health-check"
  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.timeout_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold
  tcp_health_check {
    port = var.port
  }
}

resource "google_compute_global_address" "default-static-ip" {
  name     = "default-static-ip"
}


resource "google_compute_global_forwarding_rule" "default-forwarding-rule" {
  name                  = "default-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default-target-http-proxy.id
  ip_address            = google_compute_global_address.default-static-ip.id
}

resource "google_compute_target_http_proxy" "default-target-http-proxy" {
  name     = "default-target-http-proxy"
  url_map  = google_compute_url_map.default-url-map.id
}

resource "google_compute_url_map" "default-url-map" {
  name            = "default-url-map"
  default_service = google_compute_backend_service.default-backend-service.id
}

resource "google_compute_backend_service" "default-backend-service" {
  name                    = "default-backend-service"
  protocol                = "HTTP"
  port_name               = "http"
  load_balancing_scheme   = "EXTERNAL"
  timeout_sec             = 10
  enable_cdn              = true
  health_checks           = [google_compute_health_check.example_health_check.id]
  backend {
    group           = google_compute_instance_group_manager.my_instance_group_manager.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}