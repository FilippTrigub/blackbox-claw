# This is a step by step guide based on the openclaw guide

Openclaw guide: https://docs.openclaw.ai/install/gcp

## Setup VM

export VM_NAME=openclaw-gateway

gcloud compute instances create $VM_NAME \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --boot-disk-size=20GB \
  --image-family=debian-12 \
  --image-project=debian-cloud

Note: e2-small does not have enough RAM

## Setup openclaw

run

gcloud compute ssh $VM_NAME --zone=us-central1-a --   'cat > ~/gcp_vm_setup.sh && chmod +x ~/gcp_vm_setup.sh && bash ~/gcp_vm_setup.sh'   < gcp_vm_setup.sh

gcloud compute scp /path/to/user/openclaw.json $VM_NAME:~/.openclaw/ --zone=us-central1-a

## Run the Docker image from Filipp Trigubs hub

gcloud compute ssh $VM_NAME --zone=us-central1-a --   'cd ~/openclaw && docker compose up -d'

## Alternatively run the full build

gcloud compute ssh $VM_NAME --zone=us-central1-a --   'cd ~/openclaw && docker build -t filipptri/openclaw-wacli:latest . && docker compose up -d'
