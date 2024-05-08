FROM --platform=linux/amd64 public.ecr.aws/ubuntu/ubuntu:22.04

USER root

RUN \
# Update
apt-get update -y && \
# Install Unzip
apt-get install unzip -y && \
# need wget
apt-get install wget -y && \
# vim
apt-get install vim -y && \
# git
apt-get install git -y && \
# curl
apt-get -y install curl && \
## jq
apt-get -y install jq && \
# python3
apt-get install python3 -y && \
# python3-pip
apt-get install python3-pip -y

# aws cli install
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN  ./aws/install -i /usr/local/aws-cli -b /usr/local/bin

# # update python3
# RUN python3 -m pip install --upgrade pip

# install terraform 1.4.4
RUN wget https://releases.hashicorp.com/terraform/1.4.4/terraform_1.4.4_linux_amd64.zip
RUN unzip terraform_1.4.4_linux_amd64.zip
RUN mv terraform /usr/local/bin/

# install TFSEC
RUN curl -L "$(curl -s https://api.github.com/repos/aquasecurity/tfsec/releases/latest | grep -o -E -m 1 "https://.+?tfsec-linux-amd64")" > tfsec && \
chmod +x tfsec
RUN mv tfsec /usr/bin/

# install Terrarunt
RUN wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.55.10/terragrunt_linux_amd64
RUN mv terragrunt_linux_amd64 terragrunt
RUN chmod u+x terragrunt
RUN mv terragrunt /usr/local/bin/terragrunt