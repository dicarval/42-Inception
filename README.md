#💻 Inception

## Project Overview
A Docker-based infrastructure project that sets up a complete LEMP stack (Linux, Nginx, MariaDB, PHP) along with several bonus services.

This project creates a containerized web infrastructure consisting of:
- **Core Stack**: Nginx, WordPress (PHP-FPM), and MariaDB.
- **Bonus Services**: Redis (Cache), FTP Server, Adminer (DB GUI), a static "Parallax" website, and a service health checker.
- **Security**: Usage of Docker Secrets for sensitive password management.

All services run in separate Docker containers and communicate through a custom bridge network.

## Architecture

```
┌──────────────┐                               ┌───────────────┐
│    Nginx     │───────────────────────────┐   │ Healthchecker │
│  (Port 443)  │      ┌──────────────┐     │   │               │
└──────┬───────┘      │   Adminer    │     │   └───────────────┘
       │              │ (Port 8080)  │     │
       │              └──────┬───────┘     │
       │                     │             │
┌──────▼───────┐      ┌──────▼───────┐     │
│   Parallax   │      │   MariaDB    │     │
│ (Static Site)│      │ (Port 3306)  │     │
└──────────────┘      └──────▲───────┘     │
                             │             │
                             │             │
┌──────────────┐      ┌──────▼───────┐     │     ┌──────────────┐
│     FTP      │─────►│  WordPress   │◄────└────►│    Redis     │
│  (Port 21)   │      │ (Port 9000)  │           │ (Port 6379)  │
└──────────────┘      └──────────────┘           └──────────────┘
```

### Services

- **Nginx**: Reverse proxy handling HTTPS (443); serves the WordPress site and the static Parallax site.
- **WordPress**: Runs PHP-FPM on port 9000; configured to use Redis for caching and MariaDB for storage.
- **MariaDB**: Database server exposed on port 3306.
- **Redis**: In-memory data structure store used as a cache for WordPress.
- **FTP**: File Transfer Protocol server allowing access to the WordPress volume.
- **Adminer**: Database management tool accessible via browser on port 8080.
- **Parallax**: A standalone container hosting a static website.
- **Healthchecker**: A custom service that monitors the status of other containers.

## Getting Started

### Prerequisites

- Docker Engine
- Docker Compose
- Make
- A `/data` directory structure in your home folder.

### Installation

1.  **Clone the repository**
    ```bash
    git clone <repository-url>
    cd Inception
    ```

2.  **Setup Configuration Files**
    This project expects configuration files to exist in `/home/$USER/data/`. You must create the `.env` file and the `secrets` directory there before running.

    ```bash
    # Create directory structure
    sudo mkdir -p /home/$USER/data/secrets
    ```

3.  **Build and Start**
    Run the Makefile to build images, create necessary data volumes, and start the cluster.
    ```bash
    make
	# or
	make up
    ```

## Usage

### Makefile Commands

The project includes a Makefile to automate Docker commands.

| Command | Description |
|---------|-------------|
| `make` / `make up` | Creates data directories and starts the cluster. |
| `make down` | Stops containers, removes images, **and deletes all data/volumes**. |
| `make stop` | Stops running containers without removing them. |
| `make start` | Starts existing stopped containers. |
| `make recreate` | Runs `down` followed by `up` for a fresh restart. |
| `make status` | Displays the list of running containers (`docker ps`). |

> **Warning:** The `make down` command executes `rm -rf` on your data directories. Use with caution.

## Configuration

### Environment Variables (`.env`)

You must place a `.env` file at `/home/$USER/data/.env` containing the following variables:

```env
USER=dicarval
USER_EMAIL=dicarval@student.42lisboa.com
DOMAIN_SUFFIX=.42.fr

# WordPress Config
WP_TITLE=dicarval_Inception
WP_ADMIN_USER=<admin_username>
WP_ADMIN_EMAIL=<admin_email>
```

## Docker Secrets

This project uses Docker Secrets for security. You must create the following files inside `/home/$USER/data/secrets/.` Each file should contain only the password string.

|Secret File | Description |
|------------|-------------|
|`.db_root_password` | Root password for MariaDB |
|`.db_user_password` | Password for the standard database user |
|`.wp_admin_password` | Password for the WordPress Admin account |
|`.wp_user_password` | Password for the standard WordPress user |
|`.ftp_password `| Password for the FTP user |

## Project Structure

```
Inception/
├── Makefile
├── README.md
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── bonus/
        │   ├── adminer/
        │   │   ├── Dockerfile
        │   │   └── tools/
        │   │       └── script.sh
        │   ├── ftp/
        │   │   ├── Dockerfile
        │   │   └── tools/
        │   │       └── script.sh
        │   ├── healthchecker/
        │   │   ├── Dockerfile
        │   │   └── tools/
        │   │       └── script.sh
        │   ├── parallax/
        │   │   ├── Dockerfile
        │   │   ├── conf/
        │   │   │   └── parallax_server.conf
        │   │   ├── tools/
        │   │   │   └── script.sh
        │   │   └── website/
        │   │       ├── parallax.css
        │   │       └── parallax.html
        │   └── redis/
        │       ├── Dockerfile
        │       └── tools/
        │           └── script.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   └── tools/
        │       └── script.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx_server.conf
        │   └── tools/
        │       └── script.sh
        └── wordpress/
            ├── Dockerfile
            └── tools/
                └── script.sh
```

## Docker Volumes

The project uses persistent volumes for data storage:

- **mariadb**: `/home/$USER/data/$USER$DOMAIN_SUFFIX/mariadb` → `/var/lib/mysql`
- **wordpress**: `/home/$USER/data/$USER$DOMAIN_SUFFIX/wordpress` → `/var/www/html`
- **redis**: `/home/$USER/data/$USER$DOMAIN_SUFFIX/redis` → `/data`
- **parallax**: `./requirements/bonus/parallax/website` → `/usr/share/nginx/html`

## Network

All services communicate through a custom bridge network called `inception`.

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 21, 443, 8080, and 21100-21110 are not in use
2. **Permission issues**: Check that data directories have correct permissions
3. **DNS resolution**: For local testing, add domain to `/etc/hosts`
4. **SSL warnings**: Self-signed certificates will show browser warnings
