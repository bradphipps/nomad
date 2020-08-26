locals {
  install_config_script = var.platform == "windows_amd64" ? "C:/opt/install-consul-config.ps1" : "/opt/install-consul-config"
}

resource "null_resource" "upload_configs" {

  for_each = var.config_files
  triggers = {
    contents = filemd5(each.key)
  }

  connection {
    type        = "ssh"
    user        = var.connection.user
    host        = var.connection.host
    port        = var.connection.port
    private_key = var.connection.private_key
    timeout     = "15m"
  }

  provisioner "file" {
    source      = each.key
    destination = "/tmp/consul-${basename(each.key)}"
  }
}

data "null_data_source" "configs" {
  inputs = {
    hashes = "flatten([for file in var.config_files: filemd5(file)])"
  }
}

resource "null_resource" "install_configs" {

  depends_on = [null_resource.upload_configs]
  triggers = {
    contents = data.null_data_source.configs.outputs.hashes
  }

  connection {
    type        = "ssh"
    user        = var.connection.user
    host        = var.connection.host
    port        = var.connection.port
    private_key = var.connection.private_key
    timeout     = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      local.install_config_script
    ]
  }
}
