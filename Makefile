# Load environment variables from .env
include .env
export

TF=terraform

.PHONY: help init reconfigure migrate plan apply destroy fmt validate output clean state debug

help:
	@echo ""
	@echo "Terraform Commands"
	@echo "------------------"
	@echo "make init         -> Standard terraform init"
	@echo "make reconfigure  -> Reconfigure backend"
	@echo "make migrate      -> Migrate backend state"
	@echo "make plan         -> Terraform plan"
	@echo "make apply        -> Terraform apply"
	@echo "make destroy      -> Terraform destroy"
	@echo "make fmt          -> Terraform fmt"
	@echo "make validate     -> Terraform validate"
	@echo "make output       -> Show outputs"
	@echo "make clean        -> Remove terraform cache"
	@echo "make state        -> Show terraform state list"
	@echo ""

init:
	$(TF) init

reconfigure:
	$(TF) init -reconfigure

migrate:
	$(TF) init -migrate-state

plan:
	$(TF) plan

apply:
	$(TF) apply

destroy:
	$(TF) destroy

fmt:
	$(TF) fmt -recursive

validate:
	$(TF) validate

output:
	$(TF) output

state:
	$(TF) state list

clean:
	rm -rf .terraform
	rm -f .terraform.lock.hcl

debug:
	@echo $(AWS_ACCESS_KEY_ID)