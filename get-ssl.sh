/root/acme.sh/acme.sh --issue --dns dns_aws \
--server https://acme-v02.api.letsencrypt.org/directory \
--keylength ec-384 \
--renew-hook "systemctl restart nginx" \
-d homeassistant.n1mtp.com \
-d hasswg.n1mtp.com \
-d twc.n1mtp.com

