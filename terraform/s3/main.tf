resource "aws_s3_bucket" "veeam-365-backups" {
  bucket = "veeam-365-backups"
  acl = "private"

  tags = {
    Name = "Veeam 365 Backups"
  }
 
  lifecycle_rule {
     id = "Transition to Glacier"
     enabled = true

     transition {
       days = 45
       storage_class = "GLACIER"
    }
  }
}
