# allow dns to work in jail
mkdir -p /jail/etc
cp /etc/resolv.conf /jail/etc/resolv.conf
# allow curl ssl and verify to work
mkdir -p /jail/etc
cp /etc/nsswitch.conf /jail/etc/nsswitch.conf
cp -r /etc/pki /jail/etc
cp -r /etc/ssl /jail/etc
mkdir -p /jail/usr/lib64
cp /usr/lib64/libnsspem.so /jail/usr/lib64/libnsspem.so
cp /usr/lib64/libsoftokn3.so /jail/usr/lib64/libsoftokn3.so
cp /usr/lib64/libnsssysinit.so /jail/usr/lib64/libnsssysinit.so
cp /usr/lib64/libfreebl3.so /jail/usr/lib64/libfreebl3.so
cp /usr/lib64/libnssdbm3.so /jail/usr/lib64/libnssdbm3.so
# set the default certificate bundle
echo curl.cainfo=/etc/ssl/certs/ca-bundle.crt >> /etc/php.d/curl.ini
