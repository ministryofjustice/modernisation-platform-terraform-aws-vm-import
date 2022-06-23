package main

import (
	"regexp"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestS3Creation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	roleName := terraform.Output(t, terraformOptions, "role_name")
	policyName := terraform.Output(t, terraformOptions, "policy_name")

	assert.Regexp(t, regexp.MustCompile(`^vmimport*`), roleName)
	assert.Regexp(t, regexp.MustCompile(`^vmimport-policy*`), policyName)
}
