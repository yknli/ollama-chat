#!/bin/bash
aws ssm get-parameter --name "/ollama-chat/RAILS_MASTER_KEY" --with-decryption --query "Parameter.Value" --output text > config/master.key
