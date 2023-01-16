#!/bin/bash

cd ~/Download/
tar -xvf node-v18.13.0-linux-x64.tar.xz
mv node-v18.13.0-linux-x64 /usr/local/lib/
echo "export NODE_HOME=/usr/local/lib/node-v18.13.0-linux-x64"  >> ~/.bashrc
echo "export PATH=\$PATH:\$NODE_HOME/bin" >> ~/.bashrc

source ~/.bashrc