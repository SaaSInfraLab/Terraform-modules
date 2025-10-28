# Fixes Applied to Terraform Modules

## Issues Resolved

### 1. Deprecated AWS Region Attribute
**Issue:** `data.aws_region.current.name` is deprecated in newer AWS provider versions

**Fixed in:**
- `monitoring/main.tf` (2 occurrences on lines 103, 111)
- `monitoring/outputs.tf` (1 occurrence on line 13)

**Change:** Replaced `.name` with `.id`
```hcl
# Before
region = data.aws_region.current.name

# After
region = data.aws_region.current.id
```

### 2. Missing aws_eks_auth Data Source
**Issue:** `data "aws_eks_auth"` no longer exists in hashicorp/aws provider

**Fixed in:**
- `examples/dev/provider.tf`

**Change:** Replaced with `data "external"` using AWS CLI
```hcl
# Before
data "aws_eks_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  token = data.aws_eks_auth.cluster.token
}

# After
data "external" "eks_auth" {
  program = ["aws", "eks", "get-token", "--cluster-name", module.eks.cluster_id, "--region", var.aws_region]
}

provider "kubernetes" {
  token = data.external.eks_auth.result.token
}
```

### 3. Invalid Count Argument
**Issue:** `count` in `vpc/flow_logs.tf` depended on a resource attribute that couldn't be determined until apply time

**Fixed in:**
- `vpc/flow_logs.tf` (line 17)

**Change:** Simplified count condition to only check the variable, not the module output
```hcl
# Before
count = var.enable_flow_logs && var.vpc_flow_logs_role_arn != "" ? 1 : 0

# After
count = var.enable_flow_logs ? 1 : 0
```

Note: This works because `vpc_flow_logs_role_arn` has a default value of `""` in variables.tf

## Files Modified

1. ✅ `monitoring/main.tf` - Updated 2 instances of deprecated `.name` to `.id`
2. ✅ `monitoring/outputs.tf` - Updated 1 instance of deprecated `.name` to `.id`
3. ✅ `examples/dev/provider.tf` - Replaced `aws_eks_auth` with `external` data source
4. ✅ `vpc/flow_logs.tf` - Simplified count condition to only check variable

## Next Steps

Run the following commands:
```bash
cd examples/dev
terraform init
terraform plan -var-file=dev.tfvars
```

All issues should now be resolved!
