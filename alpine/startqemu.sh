#!/data/data/com.termux/files/usr/bin/bash
export PREFIX=/data/data/com.termux/files/usr

qemu-system-x86_64 -machine q35 -m 12288 -smp cpus=7 -cpu qemu64 \
  -drive if=pflash,format=raw,read-only=on,file=$PREFIX/share/qemu/edk2-x86_64-code.fd \
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
hostfwd=tcp::47777-:47777 \
  -device virtio-net,netdev=n1 \
  -virtfs local,path=/data/data/com.termux/files/home/shared,mount_tag=hostshare,security_model=passthrough \
  -nographic alpine.img &
