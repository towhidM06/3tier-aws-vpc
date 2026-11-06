# Problems I Faced and How I Solved Them

| # | Problem | Cause | Fix |
|---|---|---|---|
| 1 | `ssh -J ... ` gave `Permission denied (publickey)` when connecting to a private server | `-i` is not forwarded to the jump host (web server) | Loaded the key into the agent: `chmod 400 todo-key.pem && ssh-add todo-key.pem`, then `ssh -J ubuntu@<WEB_IP> ubuntu@<PRIVATE_IP>` |
| 2 | Ran `ssh ... ubuntu@<private-ip>` without `-J`; got `command not found` | The private IP was treated as a command to run on the web server | Used the `-J` (jump host) option |
| 3 | Private servers needed to install packages without a public IP | Private subnets have no direct internet route | Private route tables send `0.0.0.0/0` to the NAT Gateway (outbound only); verified with `apt-get update` |
| 4 | App must connect to MySQL 8 | MySQL 8 uses `caching_sha2_password`, which PyMySQL needs `cryptography` for | Added `cryptography` to `requirements.txt` |
| 5 | MySQL refused connections from the app tier | MySQL listened on localhost only | Set `bind-address = 0.0.0.0` and limited access with the `db-sg` rule (3306 from `app-sg` only) plus a user restricted to `10.0.%` |
| 6 | App must keep running after reboot | A manually started process dies on reboot | Created a systemd unit with `Restart=always` and `systemctl enable`; verified with `sudo reboot` |
| 7 | Browser warns about the HTTPS certificate | Certificate is self-signed (no domain) | Expected; click Advanced → Proceed. A real domain with Let's Encrypt would remove the warning |
