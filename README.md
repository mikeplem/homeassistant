# My Home Assistant configurations

My Home Assistant server is running Debian and Docker containers.

All of my controllable devices are Z-Wave so I have an [Aeotec Z-Stick Gen 5](https://aeotec.com/products/aeotec-z-stick-gen5/)

## Docker Notes

While I am using Docker containers, I am running them using Podman. Since none of the containers share ports, all are setup to use host networking which means I do not have to explicitly expose ports.

## Home Assistant Files

- [automations.yaml](hass/automations.yaml)
- [configuration.yaml](hass/configuration.yaml)

## SystemD Service Files

My SystemD services are listed in their startup order. All of the containers are pointed to their latest version so I can attempt to stay as up to date as I can.

Each of the service files will attempt to download the latest container as part of a StartPre action.

- [mqtt.service](systemd/mqtt.service)
- [zwave.service](systemd/zwave.service)
- [hass.service](systemd/hass.service)
- [whisper.service](systemd/whisper.service)
- [piper.service](systemd/piper.service)
- [nginx.service](systemd/nginx.service)

### Restart Script

I have a [simple restart script](restart_hass.sh) to me keep things up to date.

## Let's Encrypt

Since my Home Assistant service is on my internal network and not directly accessibile from the internet I use DNS validation to get my SSL certs. I already have an AWS account so I am using Route53 for my DNS. I wanted something lightweight for the cert process so I chose to use [acme.sh](https://github.com/acmesh-official/acme.sh).

### Initial Cert Issuance Script

```shell
./acme.sh --issue --dns dns_aws \
--server https://acme-v02.api.letsencrypt.org/directory \
--keylength ec-384 \
-d homeassistant.n1mtp.com \
-d hasswg.n1mtp.com
```

### Renewal Script

**This still has to be tested.**

- [renew-ssl.sh](renew-ssl.sh)
- [renew-ssl.service](systemd/renew-ssl.service)
- [renew-ssl.timer](systemd/renew-ssl.timer)

## NGINX Configuration

My [NGINX config](nginx/nginx.conf) file came from what I found on HASS community forums but I found that when I ran it, the performance in the browser and companion app was slow so I ended up commenting out many options. Your mileage may vary.

