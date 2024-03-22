# Anycontainer
Anycontainer is a docker image builder for some configuration.

## General Supported Platform
1. Codeigniter 
2. Wordpress
3. Solana

### This repo is Codeigniter Platform
Stacks:
1. Mariadb 10.3
2. PHP 8.3
3. Redis 7.2.3
4. PHPMyAdmin 

## How to use
cd .anycontainer
./test_build_anycontainer.sh -b php83 
./build_anycontainer.sh -a php83 -b mariadb103 -c redis724 -d phpmyadmin521 -e node20
