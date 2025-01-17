variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# Firewall
resource "google_compute_firewall" "rules" {
  project     = var.project_id
  name        = "gke-firewall-rule"
  network     = google_compute_network.vpc.name
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["80", "443", "8080", "1000-2000"]
  }
  direction = "INGRESS"
  source_ranges = [ "0.0.0.0/0" ]
  target_tags = ["web"]
}