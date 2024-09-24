
import {
  # import the instance
  to = aws_instance.unmanaged
  id = "i-0e859ca586eef38aa"
}

# make resource id for the imported instance
#resource "aws_instance" "unmanaged" {
  # provision the instance with minimal configuration
#  ami = "ami-0819177b8e6d4947a"
#  instance_type = "t2.micro"
#}
# Self reference to terraform file resource
# used to delete the imports.tf file when terraform destroy is run
resource "terraform_data" "import_file" {

  # this stores the path to the import.tf file
  input = "${path.module}/imports.tf"

  provisioner "local-exec" {
    command = "rm -f \"${self.output}\""
    when = destroy
  }
}
