# DRAFT - IN WORK

## Project: Explicit Proxy Pass-through with Decrypt

BIG-IP transparent forward proxy configuration where client targets an upstream explicit proxy, routing through the BIG-IP, and the TCP/TLS tunnel traffic is SSLFWD decrypted/inspected.

<img src="https://github.com/user-attachments/assets/16d5b9ea-8e76-4691-8102-6738cee79ef0" width="60%">

Requires:
* BIG-IP 16.1.x and above
* SSL Orchestrator or SWG license (to enable SSLFWD)

---
### To implement via installer:

1. Run the following from the BIG-IP shell to get the installer:
    ```bash
    curl -sk https://raw.githubusercontent.com/kevingstewart/project-proxy-passthrough-decrypt/refs/heads/main/proxy-passthrough-decrypt-installer.sh -o proxy-passthrough-decrypt-installer.sh
    chmod +x proxy-passthrough-decrypt-installer.sh
    ```

2. Export the BIG-IP user:pass:
    ```bash
    export BIGUSER='admin:password'
    ```

3. Run the script to create all of the BIG-IP objects:
   ```bash
   ./proxy-passthrough-decrypt-installer.sh
   ```
---

The installer will create a basic (working) environment using a stub forging CA certificate and key, and listening on 0.0.0.0:3128, on all VLANs. Modify the above to suit your environment:
* Import your own forging CA certificate and key and replace the stubs
* Update the listening port on the virtual server
* Update the client-facing listening VLAN
* Modify source address translation (SNAT) as required between the BIG-IP and upstream explicit proxy
* If the upstream explicit proxy is not local, ensure the BIG-IP has a proper gateway route to reach it

---
### To implement manually:
1. Import the iRule
2. Import your forging CA certificate and key
3. Create the SSLFWD client SSL profile (Local Traffic -> Profiles -> SSL -> Client)
    - Configuration: Non-SSL Connections: enabled
    - SSL Forward Proxy: SSL Forward Proxy: enabled
    - SSL Forward Proxy: CA Certificate Key Chain: select your local forging CA certificate and key
    - SSL Forward Proxy: SSL Forward Proxy Bypass: enabled
    - SSL Forward Proxy: Bypass Default Action: Intercept
5. Create the SSLFWD server SSL profile (Local Traffic -> Profiles -> SSL -> Server)
    - Configuration: SSL Forward Proxy: enabled
    - Configuration: SSL Forward Proxy Bypass: enabled
    - Configuration: Secure Renegotiaion: request
    - Server Authentication: Server Certificate: require...
    - Server Authentication: Expire Certificate Reponse Control: as required for server-side certificate validation
    - Server Authentication: Untrusted Certificate Reponse Control: as required for server-side certificate validation
    - Server Authentication: Revoked Certificate Reponse Control: as required for server-side certificate validation
    - Server Authentication: Unknown Certificate Reponse Control:  as required for server-side certificate validation
    - Server Authentication: Trusted Certificate Authorities: ca-bundle.crt
7. Create an LTM virtual server
    - General Properties: Type: Standard
    - General Properties: Source Address: 0.0.0.0/0
    - General Properties: Destination Address/Mask: 0.0.0.0/0
    - Service Port: * (any) or backend proxy port (ex. 3128)
    - Configuration: HTTP Profile (Client): http
    - Configuration: SSL Profile (Client): SSLFWD client SSL profile
    - Configuration: SSL Profile (Server): SSLFWD server SSL profile
    - Configuration: VLANs and Tunnels: selected on the client-facing VLAN
    - Configuration: Source Address Translation: SNAT as required between the BIG-IP and upstream proxy
    - Configuration: Address Translation: disabled
    - Configuration: Port Translation: disabled
    - Resources (tab): iRules: imported iRule


