#!/bin/bash

# Vagrant
vagrant up
vagrant ssh
sudo adduser tanzu
sudo usermod -aG sudo tanzu
exit
vagrant reload