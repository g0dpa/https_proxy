# --------------------------------------------------------
# usage   : _make_root <common name>
# example : _make_root gilgil
# --------------------------------------------------------
rm -rf root
if [ -z "$1" ]; then
	echo "usage   : _make_root <common name>"
	echo "example : _make_root gilgil"
	exit 1
fi
COMMON_NAME="$1"

if [ -d "root" ]; then
	echo "root folder already exists"
	exit 1
fi

# --------------------------------------------------------
# make root folder
# --------------------------------------------------------
mkdir root

# --------------------------------------------------------
# make key file(root.key - cakey.pem)
# --------------------------------------------------------
openssl genrsa -out root/root.key 1024

# --------------------------------------------------------
# make csr file(root.csr)
# --------------------------------------------------------
openssl req -config openssl.cfg -new -subj "/C=KR/CN=$COMMON_NAME" -key root/root.key -out root/root.csr

# --------------------------------------------------------
# make crt file(root.crt - cacert.pem)
# --------------------------------------------------------
openssl x509 -req -days 3650 -signkey root/root.key -in root/root.csr -out root/root.crt
