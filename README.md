# Eth2 Staking

## Info

RocketPool: https://docs.rocketpool.net/guides/node/native.html#creating-service-accounts
CoinCashew: https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-testnet-prater

## Install

    cd terraform
    terraform init
    terraform plan
    terraform apply

## Post install steps

Log in to system via AWS console>instance>connect>Session manager>connect
Give a password to user `rc` and store it securely

    sudo -i
    sudo passwd rc

Then connect via classic ssh terminal
    
    ssh rc@eslastic_ip

Check that cloud-init is finished

    tail /var/log/cloud-init-output.log -n1000 -f

Give perm to validator system user to restart the validator

    sudo nano /etc/sudoers

    # Cmnd alias specification
    Cmnd_Alias RP_CMDS = /usr/bin/systemctl restart lh-validator

    # User privilege specification
    root    ALL=(ALL:ALL) ALL
    validator    ALL=(ALL) NOPASSWD: RP_CMDS

## Start services

    sudo systemctl daemon-reload
    sudo systemctl enable geth lh-beacon lh-validator
    sudo systemctl start geth lh-beacon

## Checks





## Security Hardening

- Cut firewall ssh port 22


## Maintenance

### GETH

Update Geth manually (https://geth.ethereum.org/downloads/)

    cd /tmp
    wget https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.10.16-20356e57.tar.gz
    tar xzf geth-linux-amd64-1.10.16-20356e57.tar.gz
    cp geth-linux-amd64-1.10.16-20356e57/geth /srv/geth
   
See logs:

    /srv/geth/log.sh


### Lighthouse

Update LightHouse manually (https://github.com/sigp/lighthouse/releases/)

  - cd /tmp 
  - wget https://github.com/sigp/lighthouse/releases/download/v2.1.5/lighthouse-v2.1.5-x86_64-unknown-linux-gnu.tar.gz
  - tar xzf lighthouse-v2.1.5-x86_64-unknown-linux-gnu.tar.gz
  - cp lighthouse /srv/lighthouse
  - /srv/lighthouse/lighthouse --version

See logs:

    /srv/lighthouse/log.sh


## Security

https://www.coincashew.com/coins/overview-eth/guide-or-how-to-setup-a-validator-on-eth2-mainnet/part-i-installation/guide-or-security-best-practices-for-a-eth2-validator-beaconchain-node