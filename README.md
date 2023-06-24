# My Home Assistant configurations

My Home Assistant server is running Debian and Docker containers.

The server is an Intel NUC, Intel NUC 8 Mainstream Kit (NUC8i3BEH), with 8 GB of RAM and a 250 GB NVME drive.

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

### Friget Coral Software

```shell
sudo apt install gasket-dkms libedgetpu1-std
```

### Frigate Intel VAAPI

Since the server is running an 8th gen (or better) processor and I wanted hardware acceleration I installed the following packages.

This requires added the non-free option to the apt sources list.

`cat /etc/apt/sources.list`

```shell
deb http://deb.debian.org/debian/ bookworm main non-free-firmware non-free
deb-src http://deb.debian.org/debian/ bookworm main non-free-firmware non-free

deb http://security.debian.org/debian-security bookworm-security main non-free-firmware non-free
deb-src http://security.debian.org/debian-security bookworm-security main non-free-firmware non-free

# bookworm-updates, to get updates before a point release is made;
# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports
deb http://deb.debian.org/debian/ bookworm-updates main non-free-firmware non-free
deb-src http://deb.debian.org/debian/ bookworm-updates main non-free-firmware non-free
```

```shell
sudo apt install vainfo intel-media-va-driver-non-free
```

### Frigate / Home Assistant Integration

My Home Assistant installation is using a Docker container so I installed HACS to be the Frigate addon, which makes things really nice.

## Reolink Cameras

I made sure to install the latest firmware updates on flood light and video door bell as that fixed some bugs I found with the RTSP connection.

I have three cameras but one is battery operated / solar powered so it is not linked into Frigate due to the camera not having the necessary configuration.

- [Argus 3 Pro](https://reolink.com/product/argus-3-pro/)
- [Duo Flood Light WiFi](https://reolink.com/product/reolink-duo-floodlight-wifi/)
- [Video Doorbell WiFi](https://reolink.com/product/reolink-video-doorbell-wifi/)

### Reolink Home Assistant Integration

I wanted to trigger an automation when the doorbell button was pressed. That requires the Reolink integration BUT the default video setting in the intergration interferes with the Frigate vide feed. I changed the Home Assistant integration to use flv rather than rtsp.

I ought to try using rtmp but I have not done that yet.

#### Doorbell Notifications

I have an [automation](hass/reolink_doorbell_automation.yaml) setup to notify the Home Assistant Companion App on my phone when someone presses the button on the doorbell. The linked automation is the YAML version of what I am using.

In my [Home Assistant configuration](hass/configuration.yaml) file I setup a notify group so that I can notify more than one companion app at a time.

## Neolink

**IMPORTANT: This WILL drain the battery in a matter of hours.**

I am running Neolink on my Frigate server.

It turns out that it is possible to stream the battery powered cameras into Frigate. I was curious how port 9000 worked with the camera and came across [Neolink](https://github.com/thirtythreeforty/neolink).

It would be smart to read the following as well. You may not need these but it is worth mentioning.

- [unix_service.md](https://github.com/thirtythreeforty/neolink/blob/master/docs/unix_service.md)
- [unix_setup.md](https://github.com/thirtythreeforty/neolink/blob/master/docs/unix_setup.md)

### Neolink Config

```shell
mkdir -p /neolink
```

- [systemD Service](neolink/neolink.service)
- [neolink config](neolink/neolink.toml)

#### Camera resolution

```shell
ffprobe -show_entries stream=width,height rtsp://NEOLINK_IP:8654/deck/subStream

... snip some output ...

Input #0, rtsp, from 'rtsp://NEOLINK_IP:8654/deck/subStream':
  Metadata:
    title           : Session streamed with GStreamer
    comment         : rtsp-server
  Duration: N/A, start: 0.064000, bitrate: N/A
  Stream #0:0: Video: h264 (High), yuv420p(progressive), 896x512, 90k tbr, 90k tbn, 180k tbc
  Stream #0:1: Audio: pcm_s16be, 16000 Hz, 1 channels, s16, 256 kb/s
[STREAM]
width=896
height=512
[/STREAM]
[STREAM]
[/STREAM]
```

### Camera Configs

I am using RTSP for the camera configuration which is configured through the web interface to the camera.

Something else I had done with the cameras that probably does not matter so much if you only use Frigate to send notifications is that I used the mobile app to paint the areas that I wanted the cameras to ignore.
