lambda:
	bundle config set --local path 'vendor/bundle' && bundle install
#	bundle package
#	bundle install
	zip -r aeso.zip aeso.rb vendor

.PHONY: terraform
terraform:
	cd terraform && terraform apply -auto-approve
