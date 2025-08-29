# 🛠 Stack Manager

A universal **stack management script** for Docker and Podman that supports:
- ✅ Multiple service stacks (media-stack, minio, open-webui, mandatory-services)
- ✅ Automatic detection of Docker or Podman
- ✅ Profile-based stack deployment (VPN / No-VPN / Recommendarr for media-stack)
- ✅ Interactive or non-interactive usage
- ✅ Environment variable management using `.env` files
- ✅ Optional backup & restore (coming soon)


## 📂 **Repository Structure**

├── stack-manager.sh # Main script to manage stacks  
├── media-stack.yml # Media stack (qBittorrent, Radarr, Sonarr, Jellyfin, etc.)  
├── minio.yml # MinIO object storage stack  
├── open-webui.yml # Open WebUI stack  
├── mandatory-services.yml # Portainer + Watchtower stack  
├── env-templates/ # Default .env templates for each stack  
│ ├── media-stack.env  
│ ├── minio.env  
│ ├── open-webui.env  
│ └── mandatory-services.env  
└── README.md  


## 🚀 **Usage**

### **1️⃣ Make the script executable**
```bash
chmod +x stack-manager.sh
```

### **2️⃣ Run the script**

#### ✅ Interactive Mode (No arguments) 

```bash
./stack-manager.sh
```
You will be prompted to select Action, Stack, and (if applicable) Profile.
#### ✅ Non-Interactive Mode

```bash
./stack-manager.sh <action> <stack> [profile]
```

Examples:

```bash
# Bring up media stack with VPN
./stack-manager.sh up media-stack vpn

# Bring down minio stack
./stack-manager.sh down minio

# View logs for open-webui
./stack-manager.sh logs open-webui
```

#### ✅ Supported Actions  

| Action | Description |  
|---|---|  
| up | Start the stack (with or without profile) |  
| down | Stop and remove the stack |
| start | Start containers without recreating |
| stop | Stop containers without removing |
| restart | Restart containers |
| logs | Show logs (follow mode) |
| ps | Show running containers |


#### ✅ Supported Stacks
| Stack Name | Compose File |	Profiles
|---|---|----|
|media-stack|	media-stack.yml|	vpn, no-vpn, recommendarr|
|minio|	minio.yml|	None|
|open-webui	|open-webui.yml|	None|
|mandatory-services	|mandatory-services.yml|	None|

#### ✅ Profiles (for media-stack)
- ```vpn``` → Runs media services behind VPN (Gluetun)
- ```no-vpn``` → Runs media services without VPN
- ```recommendarr``` → Runs only Recommendarr

#### ✅ Environment Files
Each stack uses its own ```.env``` file:
- ```media-stack.env```
- ```minio.env```
- ```open-webui.env```
- ```mandatory-services.env```
If an ```.env``` file does not exist, the script will prompt to create it from the template in ```env-templates/```.

#### ✅ Podman vs Docker
- If Podman is detected, it uses ```podman-compose``` and ```DOCKER_SOCKET=/run/podman/podman.sock```.
- If Docker is detected, it uses ```docker compose``` and ```DOCKER_SOCKET=/var/run/docker.sock```.

#### ✅ Examples
### Start media stack with VPN
```bash
./stack-manager.sh up media-stack vpn
```
Stop minio stack
```bash
./stack-manager.sh down minio
```
Show logs for open-webui
```bash
./stack-manager.sh logs open-webui
```
### 🔜 Planned Features
#### ✅ Automated backup & restore for:

Docker volumes

.env files

Compose files

#### ✅ Health checks and status reporting

#### ✅ Remote deployment support (SSH)

### 🛡 Requirements
Docker (with docker compose) OR Podman (with podman-compose)

bash (Linux/Mac)

chmod for making script executable

### 📜 License
MIT License. Feel free to use and modify.
