# ip-derper

1. build

```
root@ubuntu20a:~$ cd ip_derper/
root@ubuntu20a:~/ip_derper$ ls
build_cert.sh  Dockerfile  README.md
root@ubuntu20a:~/ip_derper$ docker build -t fengou/ip_derper:latest .

```

2. run

```
docker run --rm -d -p 9443:443 -p 3478:3478/udp ip_derper
```

3. modify tailscale ACLs

inserts this into tailscale ACLs: https://login.tailscale.com/admin/acls
```json
"derpMap": {
    "Regions": {
        "900": {
            "RegionID": 900,
            "RegionCode": "my_private_derper",
            "Nodes": [
                {
                    "Name": "1",
                    "RegionID": 900,
                    "HostName": "YOUR_SERVER_IP",
                    "IPv4": "YOUR_SERVER_IP",
                    "InsecureForTests": true,
                    "DERPPort": 9443
                }
            ]
        }
    }
}
```

enjoy :)