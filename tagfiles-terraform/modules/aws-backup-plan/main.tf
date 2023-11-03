resource "aws_backup_vault" "rds-backup-vault" {
  name = "rds-backup-vault"

}

// DATABASE Mysql

resource "aws_backup_plan" "rds-non-prod-mysql" {
  name = "rds-non-prod-mysql"

  rule {
    rule_name           = "non-prod-rds-mysql"
    target_vault_name   = aws_backup_vault.rds-backup-vault.name
    schedule            = "cron(0 9 * * ? *)"
    recovery_point_tags = {}
    lifecycle {
      delete_after = 3
    }
  }
}


// DATABASE Postgres

resource "aws_backup_vault" "rds-backup-vault-postgres" {
  name = "rds-backup-vault-postgres"

}

resource "aws_backup_plan" "rds-non-prod-postgres" {
  name = "rds-non-prod-postgres"

  rule {
    rule_name         = "non-prod-rds-postgres"
    target_vault_name = aws_backup_vault.rds-backup-vault-postgres.name
    schedule          = "cron(0 9 * * ? *)"
    lifecycle {
      delete_after = 3
    }
  }
}