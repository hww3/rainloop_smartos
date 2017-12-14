# hardware/rainloop

![](https://i.goopics.net/nI.png)

### What is this ?

Rainloop is a simple, modern & fast web-based client. More details on the [official website](http://www.rainloop.net/).

### Features

- Latest Rainloop **Community Edition** (stable)
- Contacts (DB) : sqlite, or mysql (server not built-in)
- With Nginx and PHP7
- Let's Encrypt setup and configuration (server name must resolve to the container)

### Build-time variables

packer build  -var-file local_vars.json -var admin_password=PASSWORD  rainloop.packer &&  triton inst create --name rainloop2 -m certbot_email=email_addr -m server_name=server.fqdn rainloop_image g4-highcpu-256M

### Ports

- **80**
- **443**

