module "vault_server" {

  depends_on = [aws_instance.server]
  count      = var.server_count

  source = "./install-vault"

  config_files = compact(setunion(
    fileset(path.module, "config/${var.profile}/vault/*.hcl"),
    fileset(path.module, "config/${var.profile}/vault/server/*.hcl"),
    fileset(path.module, "config/${var.profile}/vault/server/indexed/*${count.index}.hcl"),
  ))

  connection = {
    type        = "ssh"
    user        = "ubuntu"
    host        = "${aws_instance.server[count.index].public_ip}"
    port        = 22
    private_key = module.keys.private_key_pem
  }
}
