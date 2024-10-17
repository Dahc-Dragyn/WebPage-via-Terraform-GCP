# Define the Google Cloud project ID and region
provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central"  # Adjust as needed
}

# 1. App Engine Configuration
# Defines the App Engine application and its settings, such as the project ID and region.
resource "google_app_engine_application" "app" {
  project    = "your-gcp-project-id"
  location_id = "us-central"  # Choose a region closest to your users
}

# 2. Cloud Storage Bucket for Static Files
# Creates a Cloud Storage bucket to store your website's static files (HTML, CSS, JavaScript, images, etc.).
resource "google_storage_bucket" "bucket" {
  name          = "your-unique-bucket-name"
  location      = "US"  # Multi-regional for best availability
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page = "404.html"
  }
}

# 3. IAM Configuration for Security

# Creates a dedicated service account for App Engine to manage its resources.
resource "google_service_account" "app_engine_sa" {
  account_id   = "app-engine-sa"
  display_name = "App Engine Service Account"
}

# Grants the app engine admin role to the service account, giving it necessary permissions to manage the App Engine application.
resource "google_project_iam_member" "app_engine_sa_roles" {
  project = "your-gcp-project-id"
  role    = "roles/appengine.appAdmin"
  member  = "serviceAccount:${google_service_account.app_engine_sa.email}"
}

# Grants public read-only access to the Cloud Storage bucket for website files, allowing visitors to view the website content.
resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Optional: Secure VPC Networking Configuration

# Creates a VPC network to contain your resources and provide network isolation.
resource "google_compute_network" "default_network" {
  name = "my-vpc-network"
}

# Defines an HTTP firewall rule to allow incoming HTTP traffic to your App Engine application.
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.default_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags    = ["http-server"]
}

# Defines an HTTPS firewall rule to allow incoming HTTPS traffic to your App Engine application.
resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = google_compute_network.default_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags    = ["https-server"]
}