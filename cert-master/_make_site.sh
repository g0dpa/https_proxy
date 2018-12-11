# --------------------------------------------------------
# usage   : _make_site <common name> [<base file name>]
# example : _make_site foo.com
# --------------------------------------------------------
if [ -z "$1" ]; then
	echo "usage   : _make_site <common name> [<base file name>]"
	echo "example : _make_site foo.com"
	exit 1
fi
COMMON_NAME="$1"
BASE_FILE_NAME="$1"
if  [ ! -z "$2" ]; then
	BASE_FILE_NAME="$2"
fi

# --------------------------------------------------------
# make key file(foo.com.key)
# --------------------------------------------------------
openssl genrsa -out $BASE_FILE_NAME.key 1024

# --------------------------------------------------------
# make csr file(foo.com.csr)
#--------------------------------------------------------
openssl req -config openssl.cfg -new -subj "/C=KR/CN=$COMMON_NAME" -key $BASE_FILE_NAME.key -out $BASE_FILE_NAME.csr

# --------------------------------------------------------
# make crt file(foo.com.crt)
# --------------------------------------------------------
openssl ca -config openssl.cfg -batch -startdate 20140301000000Z -enddate 20240227000000Z -policy policy_anything -out $BASE_FILE_NAME.crt -infiles $BASE_FILE_NAME.csr

# --------------------------------------------------------
# make pkcs file(foo.com.pfx)
# --------------------------------------------------------
openssl pkcs12 -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -export -in $BASE_FILE_NAME.crt -inkey $BASE_FILE_NAME.key -out $BASE_FILE_NAME.pfx -name "$COMMON_NAME" -passin pass: -passout pass:

# --------------------------------------------------------
# make key crt file(foo.com.pem)
# --------------------------------------------------------
cat $BASE_FILE_NAME.key $BASE_FILE_NAME.crt > $BASE_FILE_NAME.pem
# rm $BASE_FILE_NAME.key // gilgil temp 2015.03.04
# rm $BASE_FILE_NAME.csr // gilgil temp 2015.03.04
# rm $BASE_FILE_NAME.crt // gilgil temp 2015.03.04
