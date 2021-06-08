terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.5.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "3.31.0"
    }
  }
}

provider "digitalocean" {
  token = var.rtoken
}

provider "aws" {
  region     = "us-west-1"
  access_key = var.aws_akey
  secret_key = var.aws_skey
}

data "digitalocean_ssh_key" "REBRAIN_SSH_PUB_KEY" {
  name = "REBRAIN.SSH.PUB.KEY"
}

resource "digitalocean_ssh_key" "makuznet" {
  name       = "makuznet"
  public_key = var.makuznet
}

resource "digitalocean_droplet" "t02" {
  count    = length(var.devs.prefix)
  image    = var.d_image
  name     = "${var.devs.username}-${var.devs.prefix[count.index]}"
  region   = var.d_region
  size     = var.d_size
  ssh_keys = [data.digitalocean_ssh_key.REBRAIN_SSH_PUB_KEY.id, digitalocean_ssh_key.makuznet.id]
  tags     = [var.tag_1, var.devs.vash_login]
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "selected" {
  name = "devops.rebrain.srwx.net."
}

resource "aws_route53_record" "makuznet_at_gmail_com" {
  count   = length(var.devs.prefix)
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.devs.vash_login}-${var.devs.prefix[count.index]}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.t02[count.index].ipv4_address]
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/ansible_inventory.tpl",
    {
      drop_num  = range(length(var.devs.prefix))
      drop_name = var.devs.prefix
      drop_ip   = digitalocean_droplet.t02.*.ipv4_address
      drop_dns  = aws_route53_record.makuznet_at_gmail_com.*.name
      drop_user = var.login_user
  })
  filename = "${path.module}/inventory.yml"
}

resource "time_sleep" "wait_30_seconds" {

  depends_on = [digitalocean_droplet.t02, local_file.inventory]

  create_duration = "30s"
}

resource "null_resource" "known_hosts" {
  count = length(var.devs.prefix)

  provisioner "local-exec" {
    command = "ssh-keyscan -t ecdsa ${digitalocean_droplet.t02[count.index].ipv4_address} >> ~/.ssh/known_hosts"
  }

  depends_on = [digitalocean_droplet.t02, time_sleep.wait_30_seconds, local_file.inventory]
}

resource "null_resource" "ansible" {

  provisioner "local-exec" {
    command = "cd ..; ansible-playbook -i terraform-do/inventory.yml main.yml"
  }

  depends_on = [local_file.inventory, null_resource.known_hosts]
}
