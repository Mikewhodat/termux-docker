# termux-docker
This repo is a combination of [this](https://github.com/egandro/docker-qemu-arm) and [this](https://github.com/mrp-yt/docker_and_portainer_on_dex), except it works and it is actively maintained.


``` sh
  these are a couple functions. I cultivated for the adaptation of this project.
And adding qemu_uefi_setup

Allows you to set up -virtfs
The ability to mount a folder from your host directory to your virtual machine.

export IMAGE=alpine.img
export SHARE_PATH=/data/data/com.termux/files/home/shared

# Create shared directory if missing
mkdir -p "$SHARE_PATH"

qemu-system-x86_64 \
  -machine q35 \
  -m 12288 \
  -smp cpus=8 \
  -drive if=pflash,format=raw,read-only=on,file="$PREFIX/s>
  -netdev user,id=n1,net=192.168.50.0/24,\
hostfwd=tcp::2222-:22,\
hostfwd=tcp::9000-:9000,\
hostfwd=tcp::8080-:8080,\
hostfwd=tcp::8111-:8111,\
hostfwd=tcp::8133-:8133,\
hostfwd=tcp::8144-:8144,\
hostfwd=tcp::8123-:8123,\
hostfwd=tcp::11444-:11444,\
hostfwd=tcp::5000-:5000,\
hostfwd=tcp::6901-:6901,\
hostfwd=tcp::6902-:6902,\
hostfwd=tcp::6903-:6903,\
hostfwd=tcp::8090-:8090,\
hostfwd=tcp::5001-:5001,\
hostfwd=tcp::47777-:47777,\
hostfwd=tcp::8000-:8000 \
  -device virtio-net,netdev=n1 \
  -virtfs local,path="$SHARE_PATH",security_model=none,mou>
  -nographic \
  "$IMAGE" &




# Memory Calculator: Convert gigabytes to megabytes
mc() {
  if [[ -z "$1" || ! "$1" =~ ^[0-9]+$ ]]; then
    echo "Usage: mc <whole_number_of_gigabytes>"
    return 1
  fi
  echo "$1 GB = $(( $1 * 1024 )) MB"
}
export PATH=$PREFIX/opt/warp-terminal/bin:$PATH
export PATH=$PREFIX/opt/warpdotdev/warp-terminal:$PATH


# Auto-prepare QEMU UEFI environment for Alpine
function qemu_uefi_setup() {
    local qemu_dir="$PREFIX/share/qemu"
    local ovmf_file="$qemu_dir/OVMF.fd"
    local url="https://retrage.github.io/edk2-nightly/bin/RELEASEX64_OVMF.fd"

    mkdir -p "$qemu_dir"

    # Check if valid OVMF file exists
    if [ ! -f "$ovmf_file" ] || [ $(stat -c%s "$ovmf_file") -lt 2000000 ]; then
        echo "[*] Fetching OVMF firmware..."
        curl -L -o "$ovmf_file" "$url" || {
            echo "[!] Failed to fetch OVMF.fd, defaulting to BIOS mode."
            return 1
        }
        echo "[+] OVMF firmware downloaded successfully."
    else
        echo "[+] Existing valid OVMF firmware detected."
    fi

    # Optionally verify /shared mount
    if [ ! -d /shared ]; then
        echo "[!] /shared not mounted, attempting to create."
        mkdir -p /shared
    fi

    echo "[✓] QEMU UEFI environment ready."
}


# Function: addport
# Purpose: Quickly open the QEMU start script for manual port edits
addport() {
    local script="$HOME/alpine/startqemu.sh"

    if [ ! -f "$script" ]; then
        echo "Error: $script not found."
        return 1
    fi

    echo "Opening $script for editing..."
    nano "$script"
}

# --- Alpine Auto ---
alpine() {
    cd ~/alpine || return 1
    termux-wake-lock 2>/dev/null
    ./startqemu.sh
    sleep 60
    ./ssh2qemu.sh
}
# Auto-run if QEMU isn't active
if ! pgrep -f "qemu" >/dev/null 2>&1; then
    alpine &
fi
# --- End Alpine Auto ---



These were a couple of functions that I built for my .bashrc and it is compatible with .zshrc
  ```


## How to use: Docker

  Create the virtual machine with:
  https://github.com/Mikewhodat/termux-docker.git
  ``` sh
 curl -o setup.sh https://raw.githubusercontent.com/Mikewhodat/termux-docker/main/setup.sh && chmod 755 ./setup.sh && ./setup.sh
  ```

  And start it with:
  
  ``` sh
  # Login credentials → USER: root PASSWORD: groovy
  ~/alpine/startqemu.sh
  ```
  
  Inside this virtual machine you can use docker as you would do in a normal computer.

## How to use: Portainer

  Run it with
  ``` sh
  # Run the container → Then open this URL in your browser to use it: http://localhost:9000
  docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v ~/docker-volumes/portainer:/home portainer/portainer-ce && echo " * Open http://localhost:9000 in your browser to use portainer." && echo " * You can make sure the container is running with 'docker ps'."
  ```

  If you want to access the Portainer Dashboard from another device on your same network, you will need your device local IP address.
  
  ``` sh
  # Example:
  http://192.168.123.123:9000
  ```

## How to use: Kubernetes

  Run it with
  ```sh
  # Run this command to login interactively into the container and run commands like 'kubectl'.
  # WARNING: This container won't do anything by itself if you make it run on background.
  docker run -it --entrypoint /bin/sh -p 6443:6443 -p 2379:2380 -p 10250:10250 -p 10259:10259 -p 10257:10257 -p 30001:32767 -v ~/docker-volumes/kubernetes:/home -v /var/run/docker.sock:/var/run/docker.sock alpine/k8s:1.24.12
  ```

## How to use: Prometheus
  ```sh
  # WARNING: You must edit the command to change "/path/to/prometheus.yml" by the actual file.
  # See: https://github.com/prometheus/prometheus/blob/main/documentation/examples/prometheus.yml
  docker run -d -p 9090:9090 -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml --name=prometheus --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v ~/docker-volumes/prometheus:/home prom/prometheus && echo " * You can make sure the container is running with 'docker ps'."
  ```

## How to use: Grafana

  ```sh
  # Run the container → Then open this URL in your browser to use it: http://localhost:3000
  docker run -d -p 3000:3000 --name=grafana --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v ~/docker-volumes/grafana:/home grafana/grafana-oss:8.5.22 && echo " * Open http://localhost:3000 in your browser to use grafana." && echo " * You can make sure the container is running with 'docker ps'."
  ```

## Demo

![doc](https://user-images.githubusercontent.com/3357792/229592523-72232b5a-02ee-478a-9d25-420472fbce47.jpg)

# Other relevant reference data

* [Kubernetes Port reference](https://kubernetes.io/docs/reference/networking/ports-and-protocols/): We are opening the necessary ports, but you can double check here.
* [Kubernetes docker image reference](https://hub.docker.com/r/alpine/k8s): The image we use include Helm and other stuff you would normally use.
* [Portainer docker image reference](https://hub.docker.com/r/portainer/portainer-ce): Noting super relevant here. Just for reference.
* [Prometheus docker image reference](https://hub.docker.com/r/prom/prometheus): You can find an example prometheus.yaml file in [the prometheus github repo](https://github.com/prometheus/prometheus/blob/main/documentation/examples/prometheus.yml).
* [Grafana docker image reference](https://hub.docker.com/r/grafana/grafana/tags): Nothing super relevant here. Check [their official docs](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/) also if you want.


## FAQ

* **Where do I run the commands?** In [Termux](https://termux.dev/en/). You can download it from [F-Droid](https://www.f-droid.org/).
* **I can't run portainer/kubernetes!** You need to setup docker first, follow the steps.
* **It is really actively maintained?** Yes. Even if for some wild reason I don't have a lot of time to fix bugs myself, I tend to revise PRs quite fast.
* **Can I open issues?**: By general rule only PRs are allowed, but if an issue show a certain degree of reseach prior to submit it, or it is part or a reseach process, I will be glad to discuss it. Any other issue will be closed without answer.
* **Does my device need to be rooted?** No.
* **Do I need to run the docker images every time?** No. You can see we are using "--restart=always" which means the images will run automatically every time you run "startqemu.sh".
* **Give me a short explanation about everything** The setup.sh script uses qemu to create a virtual machine based on an alpine iso image, then docker is installed on it. From this point you can optionally install the rest of the software using docker. Docker run containers. Kubernetes is used for automated deployment. Portainer allow you to manage containers visually. Prometheus can be connected to everything to gather data. Grafana is a frontent for prometheus, mostly used to check logs.
* **How do I make changes in a container permanent?** You can see when we use 'docker run' we are always using the -v parameter. That's a volume. After you exit your container, volumes will remain. By default we use ~/docker-volumes/container-name. Remember this IS inside the qemu virtual machine, NOT in your Termux directories.
