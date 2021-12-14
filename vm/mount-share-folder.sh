#!/bin/bash

/usr/bin/vmhgfs-fuse .host:/workspaces /mnt/workspaces -o subtype=vmhgfs-fuse,allow_other -o uid=1000 -o gid=1000 -o umask=0002

