################################################################################
# File System
################################################################################

output "arn" {
  description = "Amazon Resource Name of the file system"
  value       = try(aws_efs_file_system.this[0].arn, null)
}

output "id" {
  description = "The ID that identifies the file system (e.g., `fs-ccfc0d65`)"
  value       = try(aws_efs_file_system.this[0].id, null)
}

output "dns_name" {
  description = "The DNS name for the filesystem per [documented convention](http://docs.aws.amazon.com/efs/latest/ug/mounting-fs-mount-cmd-dns-name.html)"
  value       = try(aws_efs_file_system.this[0].dns_name, null)
}

output "size_in_bytes" {
  description = "The latest known metered size (in bytes) of data stored in the file system, the value is not the exact size that the file system was at any point in time"
  value       = try(aws_efs_file_system.this[0].size_in_bytes, null)
}
