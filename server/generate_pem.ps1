openssl req -x509 -newkey rsa:4096 -nodes -out ".\certificates\AlterBahnhofCert.pem" -keyout ".\certificates\AlterBahnhofKey.pem" -days 365
# Parameters given:
# Country Name (2 letter code) [AU]:DE
# State or Province Name (full name) [Some-State]:Baden-Wuerrtemberg
# Locality Name (eg, city) []:Tuebingen
# Organization Name (eg, company) [Internet Widgits Pty Ltd]:Alter Bahnhof
# Organizational Unit Name (eg, section) []:
# Common Name (e.g. server FQDN or YOUR name) []:AlterBahnhof
# Email Address []:hallo@seminarhaus-im-bahnhof.de
