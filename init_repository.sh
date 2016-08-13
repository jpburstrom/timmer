#!/bin/sh

#Upgrade git-annex repository to v6
git-annex upgrade && 

#Enable the S3 remote
git-annex enableremote timmers3 && 

#Get all files from remote
git-annex get
