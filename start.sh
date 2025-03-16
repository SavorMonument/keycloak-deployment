#!/usr/bin/bash 

install_docker_for_debian() {
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

if command -v docker &> /dev/null
then
    echo "Docker is installed, skipping installation"
else
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
        echo "Installing docker for debian, if not root, do not forget to relog to get access to docker"
        install_docker_for_debian
        usermod -aG docker $(whoami)
    elif [[ "$ID" == "rhel" || "$ID_LIKE" == *"rhel"* ]]; then
        echo "This docker for RHEL"
    else
        echo "Missing docker installer for this distribution: $ID"
    fi
  else
      echo "/etc/os-release file not found. Cannot determine the distribution."
  fi
fi

docker build -t keycloak-deploy .
sudo mkdir -p /opt/keycloak/conf/

if [ "$1" == "down" ]; then
  docker compose down
elif [ "$1" == "upgrade" ]; then
  docker build -t keycloak-deploy .
  docker compose up -d
else
  docker compose up -d
  docker logs -f keycloak-0
fi
