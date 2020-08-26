locals {
  # fake connection to satisfy module requirements
  connection = {
    type        = "ssh"
    user        = "ubuntu"
    host        = "192.168.1.1"
    port        = 22
    private_key = "example"
  }
}

module "nomad_server" {

  count = var.server_count

  source = "../install-nomad"

  nomad_version = count.index < length(var.nomad_version_server) ? var.nomad_version_server[count.index] : var.nomad_version

  nomad_sha = count.index < length(var.nomad_sha_server) ? var.nomad_sha_server[count.index] : var.nomad_sha

  nomad_local_binary = count.index < length(var.nomad_local_binary_server) ? var.nomad_local_binary_server[count.index] : var.nomad_local_binary

  config_files = compact(setunion(
    fileset(path.module, "config/${var.profile}/nomad/*.hcl"),
    fileset(path.module, "config/${var.profile}/nomad/server/*.hcl"),
    fileset(path.module, "config/${var.profile}/nomad/server/indexed/*${count.index}.hcl"),
  ))

  connection = local.connection
}

module "nomad_client_linux" {

  count = var.client_count

  source = "../install-nomad"

  nomad_version = count.index < length(var.nomad_version_client_linux) ? var.nomad_version_client_linux[count.index] : var.nomad_version

  nomad_sha = count.index < length(var.nomad_sha_client_linux) ? var.nomad_sha_client_linux[count.index] : var.nomad_sha

  nomad_local_binary = count.index < length(var.nomad_local_binary_client_linux) ? var.nomad_local_binary_client_linux[count.index] : var.nomad_local_binary

  config_files = compact(setunion(
    fileset(path.module, "config/${var.profile}/nomad/*.hcl"),
    fileset(path.module, "config/${var.profile}/nomad/client-linux/*.hcl"),
    fileset(path.module, "config/${var.profile}/nomad/client-linux/indexed/*${count.index}.hcl"),
  ))


  connection = local.connection
}

module "nomad_client_windows" {

  count = var.windows_client_count

  source = "../install-nomad"

  nomad_version = count.index < length(var.nomad_version_client_windows) ? var.nomad_version_client_windows[count.index] : var.nomad_version

  nomad_sha = count.index < length(var.nomad_sha_client_windows) ? var.nomad_sha_client_windows[count.index] : var.nomad_sha

  nomad_local_binary = count.index < length(var.nomad_local_binary_client_windows) ? var.nomad_local_binary_client_windows[count.index] : var.nomad_local_binary

  config_files = compact(setunion(
    fileset(path.module, "config/${var.profile}/nomad/*.hcl"),
    fileset(path.module, "config/${var.profile}/nomad/client-windows/*.hcl"),
    fileset(path.module, "config/${var.profile}/nomad/client-windows/indexed/*${count.index}.hcl"),
  ))

  connection = local.connection
}
