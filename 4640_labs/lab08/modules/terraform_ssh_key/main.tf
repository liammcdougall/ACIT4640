resource "tls_private_key" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key
  algorithm = "ED25519"

  # Generate key-pair files in current directory when creating the key pair
  # For use when SSHing to the EC2 instances
  provisioner "local-exec" {
    # Reference: https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
    # Tutorial: https://spacelift.io/blog/terraform-provisioners
    # Using a terraform variable in shell https://stackoverflow.com/questions/71178041/how-to-insert-terraform-variable-in-shell-script
    command = <<DELIM
      echo '${tls_private_key.main.private_key_openssh}' > '${var.ssh_key_name}.pem'
      echo '${tls_private_key.main.public_key_openssh}' > '${var.ssh_key_name}.pub'
      chmod 400 ./'${var.ssh_key_name}.pem'
    DELIM

    when = create
  }
}

# Create a data source  that will be used to delete the key pair files when the
# infrastructure is destroyed. This avoids polluting the local filesystem with
# key files
resource "terraform_data" "delete_key_pair" {
  # Reference: https://developer.hashicorp.com/terraform/language/resources/terraform-data
  # Input stores value that is accessed in the provisioner block as output
  input = {
    key_name = var.ssh_key_name
  }
  # Delete the locally created key files on destroy
  provisioner "local-exec" {
    # Reference: https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
    command = "rm -f \"${self.output.key_name}.pem\" \"${self.output.key_name}.pub\""
    when    = destroy
  }
}

# Sync SSH public key with AWS
resource "aws_key_pair" "main" {
  # Reference: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
  key_name   = "${var.ssh_key_name}"
  public_key = tls_private_key.main.public_key_openssh
}