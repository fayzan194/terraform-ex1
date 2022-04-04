
provider "aws" {
    region = "us-west-2"
    secret_key = "Z1le2A7N6BtUMV4q9YL94vzPqs9pICAvPBUpKBcL"
    access_key = "AKIAQ3UAVJGPKCIU76Q4"
}

resource "aws_s3_bucket" "f1" {
  bucket = "fayzan-bucket123"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "f1-acl" {
  bucket = aws_s3_bucket.f1.id
  acl    = "public-read"
}

# resource "aws_s3_bucket_public_access_block" "s3block-access" {
#   bucket                  = aws_s3_bucket.f1.id
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

resource "aws_s3_bucket_website_configuration" "f1-website-conf" {
  bucket = aws_s3_bucket.f1.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}




resource "aws_cloudfront_distribution" "s3-dist" {
    origin {
        domain_name = aws_s3_bucket.f1.bucket_regional_domain_name
        origin_id = aws_s3_bucket.f1.bucket_regional_domain_name
    }
    enabled = true
    default_root_object = "index.html"

    default_cache_behavior {
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD", "OPTIONS"]
      target_origin_id       = aws_s3_bucket.f1.bucket_regional_domain_name
      viewer_protocol_policy = "redirect-to-https"
      compress = true

      forwarded_values {
        query_string = false
        cookies {
          forward = "none"
      }
    }
    }
 restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

viewer_certificate {
    cloudfront_default_certificate = true
  }
}