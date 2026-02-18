# This is a step by step guide based on the openclaw guide

Openclaw guide: https://docs.openclaw.ai/install/gcp

## Setup VM

gcloud compute instances create openclaw-gateway \
  --zone=us-central1-a \
  --machine-type=e2-medium \
  --boot-disk-size=20GB \
  --image-family=debian-12 \
  --image-project=debian-cloud

Note: e2-small does not have enough RAM

## Setup openclaw

run

gcloud compute ssh openclaw-gateway --zone=us-central1-a --   'cat > ~/gcp_vm_setup.sh && chmod +x ~/gcp_vm_setup.sh && bash ~/gcp_vm_setup.sh'   < gcp_vm_setup.sh

gcloud compute scp /path/to/user/openclaw.json openclaw-gateway:~/.openclaw/ --zone=us-central1-a



# delte later

gcloud compute scp ~/.openclaw/openclaw.json openclaw-gateway:~/.openclaw/ --zone=us-central1-a
