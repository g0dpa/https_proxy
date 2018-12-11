# --------------------------------------------------------
# call _clear_site
# --------------------------------------------------------
./_clear_site.sh

# --------------------------------------------------------
# initialize demoCA folder
# --------------------------------------------------------
mkdir demoCA
mkdir demoCA/newcerts
mkdir demoCA/private

# --------------------------------------------------------
# copy root files
# --------------------------------------------------------
cp root/root.key demoCA/private/cakey.pem
cp root/root.crt demoCA/cacert.pem

# --------------------------------------------------------
# make other files
# --------------------------------------------------------
touch ./demoCA/index.txt
echo 01 > ./demoCA/serial

