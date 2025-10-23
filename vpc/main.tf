// module-level locals
locals {
  // map AZ => index to get deterministic ordering for for_each
  az_map = { for idx, az in var.azs : az => idx }
}

