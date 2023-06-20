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

### MQTT Configuration

I had to make sure the MQTT broker (server) on my Home Assistant server was listening on all interfaces. Because this network is on my private network, I do not have authentication or SSL setup in MQTT. This is not great practice but it is a choice I made.

```
listener 1883
allow_anonymous true
```

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

## Frigate NVR

[Frigate NVR](https://frigate.video/)

I purposely do NOT have my cameras configured into Home Assistant directly. I am using the Frigate addon to give me the camera feeds. My reasoning, is I would rather have a single source of truth when it comes to the cameras.

I replaced my Ring system with [Reolink](https://reolink.com/) devices and using Frigate as the network video recorder (NVR)

### Notifications

I am [using this blueprint](https://community.home-assistant.io/t/frigate-mobile-app-notifications-2-0/559732) to configure the notifications. You may also want to use the [Github link to the blueprint](https://github.com/SgtBatten/HA_blueprints/tree/main/Frigate%20Camera%20Notifications).

I also [found this website](https://github.com/SgtBatten/HA_blueprints/tree/main/Frigate%20Camera%20Notifications) to be somewhat helpful as another reference. It appears to be talking about a slightly older version of the blueprint but it was enough to give me some answers to questions I had.

### Frigate Host Directory Structure

```shell
sudo mkdir -p /frigate/config
sudo mkdir -p /frigate/storage
```

### Frigate Configs

The server is a [Zotac ZBOX BI325 computer](https://www.zotac.com/ca/product/mini_pcs/zbox-bi325) running 8 GB of RAM and a 240 GB SSD. It is running Debian 12 (Bookworm). To help with the detection, I bought the [Coral M.2 A+E keyed TPU](https://coral.ai/products/m2-accelerator-ae). The computer had a WiFi adapter in its M.2 slot but I am using the ethernet connection so I do not need WiFi.

Rather than installing Docker, I install podman and podman-compose.

- [Docker compose config](frigate/frigate-compose.yaml)
    - The Docker compose file is placed in `/frigate/`
- [Frigate config](frigate/config.yml)
    - The Frigate config file is placed in `/frigate/config/`
- [SystemD Service](frigate/frigate.service)

### Frigate / Home Assistant Integration

My Home Assistant installation is using a Docker container so I installed HACS to be the Frigate addon, which makes things really nice.

## Reolink Cameras

I have three cameras but one is battery operated / solar powered so it is not linked into Frigate due to the camera not having the necessary configuration.

I do wonder how true this is since the Reolink phone app can see the camera. It has to be using some connection.

- [Argus 3 Pro](https://reolink.com/product/argus-3-pro/)
- [Duo Flood Light WiFi](https://reolink.com/product/reolink-duo-floodlight-wifi/)
- [Video Doorbell WiFi](https://reolink.com/product/reolink-video-doorbell-wifi/)

### Camera Configs

I am using RTSP for the camera configuration which is configured through the web interface to the camera.

Something else I had done with the cameras that probably does not matter so much if you only use Frigate to send notifications is that I used the mobile app to paint the areas that I wanted the cameras to ignore.
