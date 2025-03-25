# Nginx SSL Manager

A powerful and user-friendly Bash script to automate Nginx configuration, reverse proxy setup, and SSL installation using Let's Encrypt. Perfect for quickly setting up secure websites with minimal effort.

---

## 📌 Features
- Supports configuration for:
  - `domain.com` only
  - `www.domain.com` only
  - Both `domain.com` and `www.domain.com`
- Offers two modes:
  - **Document Root:** Create a new or use an existing document root.
  - **Reverse Proxy:** Configure reverse proxy with a specified port.
- Automatic creation of Nginx configuration files.
- Auto-detection and installation of required dependencies (Nginx & Certbot).
- Automatic SSL installation and configuration via Let's Encrypt.
- Comprehensive error handling.

---

## 📂 File Structure
```
/ (root directory)
├── nginx-setup.sh   # Main Bash script
├── README.md        # Documentation (this file)
```

---

## 🚀 Usage
### 1. Clone the Repository
```
git clone https://github.com/vimrul/nginx-ssl-manager.git
cd nginx-ssl-manager
```

### 2. Make the Script Executable
```
sudo chmod +x nginx-setup.sh
```

### 3. Run the Script
```
sudo ./nginx-setup.sh
```

---

## 📖 Script Workflow
1. Prompts user to enter a domain name.
2. Asks if the configuration is for `domain.com`, `www.domain.com`, or both.
3. Prompts for configuration type:
   - Document Root
   - Reverse Proxy
4. If Document Root:
   - Allows creation of a new document root or use of an existing one.
5. If Reverse Proxy:
   - Asks for the port to proxy requests to.
6. Creates the Nginx configuration file and enables it.
7. Tests Nginx configuration and reloads the service.
8. Checks if Certbot is installed. Installs it if missing.
9. Offers to install SSL using Certbot.

---

## 🔐 Example Usage
### For Document Root:
```
sudo ./nginx-setup.sh
```
- Enter domain: `example.com`
- Choose configuration type: `Document Root`
- Choose document root option: `Create a new document root`
- Creates Nginx configuration and enables it.
- Asks to install SSL with Let's Encrypt.

### For Reverse Proxy:
```
sudo ./nginx-setup.sh
```
- Enter domain: `example.com`
- Choose configuration type: `Reverse Proxy`
- Enter reverse proxy port: `3000`
- Creates Nginx configuration and enables it.
- Asks to install SSL with Let's Encrypt.

---

## ⚙️ Requirements
- Ubuntu/Debian-based Linux systems.
- `nginx`
- `certbot` & `python3-certbot-nginx`

---

## 📌 Notes
- Make sure your DNS records are correctly pointed to your server before running the script.
- The script will automatically install missing dependencies.

---

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
