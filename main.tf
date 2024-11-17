# Red personalizada

resource "google_compute_network" "vpc_network" {
  name                    = "audit-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet" {
  name          = "audit-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

# Regla de firewall para permitir tráfico interno entre VMs

resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.1.0/24"]
}

# Regla de firewall para permitir SSH desde el exterior

resource "google_compute_firewall" "allow-ssh" {
  name = "allow-ssh"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.name
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# Máquina virtual objetivo con servicios y oonfiguraciones vulnerables

resource "google_compute_instance" "target_vm" {
  name         = "target-vm"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  tags         = ["ssh", "target"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    # paquetes básicos
    sudo apt-get install -yq build-essential net-tools python3-pip rsync git curl ufw
    # lynis
    cd /usr/local && git clone https://github.com/CISOfy/lynis
    # maldet
    cd /usr/local && git clone https://github.com/rfxn/linux-malware-detect
    cd /usr/local/linux-malware-detect && sudo ./install.sh
    # servicio: web - apache
    sudo apt install -y apache2 openssh-server
    sudo systemctl enable apache2
    sudo systemctl start apache2
    sudo ufw allow 'WWW'
    # servicio: ssh - openssh
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    sudo ufw allow ssh
    # error de permisos
    sudo chmod 777 /etc/shadow
    # fortificación
  EOF

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {}
  }
}

# Máquina virtual de referencia

resource "google_compute_instance" "reference_vm" {
  name         = "reference-vm"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  tags         = ["ssh", "reference"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt update
    # paquetes básicos
    sudo apt install -yq build-essential net-tools git
    # lynis
    cd /usr/local && git clone https://github.com/CISOfy/lynis
    echo 'export PATH="$PATH:/usr/local/lynis"' >> ~/.bashrc
  EOF

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {}
  }
}

