terraform {
    backend "s3" {
        bucket         = "tlbcit-mod-remote-state-2024-11-26-new"
        key            = "terraform.tfstate"
        dynamodb_table = "mod-remote-state-lock"
        region         =  "us-west-2" 
        encrypt        = true
    }
}
