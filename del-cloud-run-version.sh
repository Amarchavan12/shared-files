#!/bin/bash

# Take necessary input from user

read -p "Please enter GCP project-ID :" project-id
read -p "Please enter the date befor which all the revisions need to be deleted (example : 2024-04-16) :" dt
read -p "Please enter name of service :" SERVICE_NAME
read -p "Please enter region :" REGION

# Switch to the GCP project according to provided project ID

gcloud config set project $project-id

# Create a unique file name

dte=$(date +"%Y-%m-%d-%H-%M-%S")
filename="$dte.txt"
END_DATE="${dt}T00:00:00Z"

# List all revisions and save into a file

gcloud run revisions list --service=${SERVICE_NAME} --platform=managed --region=${REGION} --format="value(metadata.name,metadata.creationTimestamp)" > $filename

# Filter revisions by creation date using awk

old_revision=$(awk -v end_date="$END_DATE" '
{
  split($2, a, "T");
  split(end_date, b, "T");
  if (a[1] < b[1]) {
    print $1;
  }
}' $filename)

# Delete all old versions

for i in $old_revision; do gcloud run revisions delete $i --region=asia-south1 --quiet; done
