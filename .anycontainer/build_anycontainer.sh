#!/bin/bash
set -eux
#set -v

# This script is for building
# all stack variations and check for errors
# during the mysqli and pdo connect.
# This Script is build for Linux
# Info:
# This Script works on WSL2 _but_ you cant use
# WSL2 Windows Host mounted paths for the data.

dc=$(which docker-compose)
osversion=$(uname)
version=(mariadb103 mariadb104 mariadb105 mariadb106)
dbarr=(mariadb103 mariadb104 mariadb105 mariadb106 mysql57 mysql8)
redisarr=(redis724)
nodearr=(node20)
phparr=(php83)
phpmyadminarr=(phpmyadmin521)

phpversion=default
rdbmsversion=default
nodeversion=default
nosqlversion=default
phpmyadminversion=default

checkdep() {

echo "### checking dependencies"
which docker || { echo 'Executable not found: docker' ; exit 1; }
which docker-compose || { echo 'Executable not found: docker-compose' ; exit 1; }
which curl || { echo 'Executable not found: curl' ; exit 1; }
which sed || { echo 'Executable not found: sed' ; exit 1; }
}

usage() {
echo "Usage:"
echo "       -a = choose PHP Version"
echo "            valid values are: php54, php56, php71, php72, php73, php74, php8, php81, php82, php83"
echo "            "
echo "       -b = Choose RDBMS with version"
echo "            valid values are: mariadb103, mariadb104, mariadb105, mariadb106, mysql57, mysql8, postgresql80 "
echo "            "
echo "       -c = Choose NoSQL with version"
echo "            valid values are: redis724,mongodb999 "
echo "            "
echo "       -d = Choose PHPMyAdmin with version"
echo "            valid values are: phpmyadmin521"
echo "            "
echo "       -e = Choose Nodeversion"
echo "            valid values are: node16, node20"
echo "            "
echo -e " \nAttention: !!! SCRIPT REMOVES ALL DATA IN 'data/mysql/*' !!!"
}

# build stack variations
build () {

        echo "### building $buildtarget-$version"

                # removing old mysql data, old data prevents mysql
                # from starting correct
                echo -e "### cleaning old mysql data"
                sudo rm -rf ./data/mysql/*
                echo -e "### building ./build/$buildtarget-$version.env \n"
                $dc --env-file ./build/$buildtarget-$version.env up -d --build
                # wait for mysql to initialize
                sleep 30
                # check definitions
                curlmysqli=$(curl -s --max-time 15 --connect-timeout 15 http://localhost/test_db.php |grep proper |wc -l |tr -d '[:space:]')
                curlpdo=$(curl -s --max-time 15 --connect-timeout 15 http://localhost/test_db_pdo.php |grep proper |wc -l |tr -d '[:space:]')

                        # check if we can create a successfull connection to the database
                        # 1=OK  everything else is not ok
                        if [ "$curlmysqli" -ne "1" ]; then
                                echo -e "### ERROR: myqli database check failed expected string 'proper' not found \n"
                                echo "### ...stopping container"
                                $dc --env-file ./build/$buildtarget-$version.env down
                                exit
                        else
                                echo -e "\n OK - mysqli database check successfull \n"
                                sleep 3
                        fi

                        if [ "$curlpdo" -ne "1" ]; then
                                echo -e "### ERROR: pdo database check failed expected string 'proper' not found \n"
                                echo "### ...stopping container"
                                $dc --env-file ./build/$buildtarget-$version.env down
                                exit
                        else
                                echo -e "\n OK - pdo database check successfull \n"
                                sleep 3
                        fi

                echo "### ... stopping container"
                $dc --env-file ./build/$buildtarget-$version.env down --remove-orphans
}

buildenvfile () {

cat sample.env > ./build/"$buildtarget"-"$version".env
sed -i "s/COMPOSE_PROJECT_NAME=cidevany/COMPOSE_PROJECT_NAME=$buildtarget-build/" ./build/"$buildtarget"-"$version".env
sed -i "s/PHPVERSION=php8/PHPVERSION=$buildtarget/" ./build/"$buildtarget"-"$version".env
sed -i "s/NODEVERSION=php8/NODEVERSION=$nodeversion/" ./build/"$buildtarget"-"$version".env
sed -i "s/DATABASE=mysql8/DATABASE=$version/" ./build/"$buildtarget"-"$version".env
sed -i "s/ANYCONTAINER_IMAGE=default/ANYCONTAINER_IMAGE=$version/" ../.devconfig
}

prepare () {

# generate all .env files for building
echo "### building env file"
mkdir -p ./build
rm -rf ./build/"$buildtarget"*
}

cleanup () {

echo "### cleaning old env file"
rm -rf ./build/"$buildtarget"*
sudo rm -rf ./data/mysql/*
sudo rm -rf ./data/mysql/.my-healthcheck.cnf
}

while getopts ":a:b:c:d:e:" opt;
do
        case "${opt}" in
                a) phpversion=${OPTARG};;
                b) rdbmsversion=${OPTARG};;
                c) nosqlversion=${OPTARG};;
                d) phpmyadminversion=${OPTARG};;
                e) nodeversion=${OPTARG};;
        esac
        no_args="false"
done
shift $((OPTIND-1))

# check user input
[[ "$no_args" == "true" ]] && { usage; exit 1; }

# check if we are running on Linux
if [[ $osversion != 'Linux' ]]; then
        echo "This Script only supports Linux sorry :("
        exit
fi

echo "> $phpversion"
echo "> $rdbmsversion"
echo "> $nosqlversion"
echo "> $phpmyadminversion"
echo "> $nodeversion"

# we don't want to test. we wanto build
buildtarget=$phpversion
version=$rdbmsversion

checkdep
prepare
buildenvfile "$buildtarget" "$version"
build "$buildtarget" "$version"
cleanup

exit