# Terraform AWS Static Website Hosting with Jenkins Pipeline

This repository demonstrates how to host a static website on an Amazon EC2 instance using Nginx as the web server. Additionally, it incorporates Jenkins and a Pipeline job to automatically update the website whenever a Git commit occurs using webhooks.

This project aimed to build on my previous knowledge gained from creating a simple Jenkins pipeline that stored the website on a S3 bucket. This can be seen in this repo: https://github.com/ShafiqueMahen/static-website

## Overview
The project breaks down into the following steps:

Provisioning EC2 Instances: Use Terraform to provision two EC2 instances. One instance will act as the web server hosting the static website, and the other instance will serve as the Jenkins server. Both respective servers will have Nginx and Jenkins installed during this process.

Setting up Nginx: Configure Nginx on the web server to serve the static website files.

Setting up Jenkins: Configure Jenkins for automated deployments.

Creating the Jenkins Pipeline: Define a Jenkins Pipeline job that monitors this Git repository for new commits and triggers a deployment whenever changes occur.

Automating Website Updates: Configure the Jenkins Pipeline to remove the current website files on the web server and then copy the latest website files.

