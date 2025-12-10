# AWS RDS automatically creates and manages the secret when manage_master_user_password = true
# The secret ARN is available in aws_db_instance.main.master_user_secret[0].secret_arn
# No need for a data source - we can use the ARN directly from the RDS instance
