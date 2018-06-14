# Start with the latest Ubuntu image
FROM ubuntu

# Copying Vendor to tmp
# This will copy the sources for both Openssl and the Patched Python code
COPY vendor /tmp

#set ENV
ENV OPENSSL_FIPS=1

# Installing Dependencies
RUN apt-get update && apt-get install -y build-essential make bzip2 libbz2-dev zlib1g-dev libffi-dev libc6 fakeroot

#Switch directory to the tmp folder where the source code for Openssl and Patched Python are located
RUN cd /tmp \
 && tar -xvf openssl-1.0.2h.tar.gz \
 && tar -xvf openssl-fips-2.0.12.tar.gz  \
 && tar -xvf Python-3.6.0.tar.gz

#Remove previous OPENSSL
RUN rm -r /usr/local/ssl;exit=0

#Build OpenSSL Fips Module and then FIPS-enabled OpenSSL
RUN cd /tmp && cd openssl-fips-2.0.12 && ./config && make && make install
RUN cd /tmp && cd openssl-1.0.2h && ./config shared fips && make && make install

#Replace System OpenSSL with FIPS enabled OpenSSL
RUN ln -s -f /usr/local/ssl/bin/openssl /usr/bin/openssl
RUN ln -s -f /usr/local/ssl/lib /usr/lib/ssl
RUN ln -s -f /usr/local/ssl/include/openssl/ /usr/include/ssl

#Move System's libcrypto and libssl shared objects
# RUN mv /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /lib/x86_64-linux-gnu/old_libcrypto.so.1.0.0 && mv /lib/x86_64-linux-gnu/libssl.so.1.0.0 /lib/x86_64-linux-gnu/old_libssl.so.1.0.0

#Copy new FIPS-enabled libcrypto and libssl shared objects
RUN cp /usr/local/ssl/lib/libcrypto.so.1.0.0 /lib/x86_64-linux-gnu/ && cp /usr/local/ssl/lib/libssl.so.1.0.0 /lib/x86_64-linux-gnu/

#Set ENV
ENV LDFLAGS="-L/usr/local/ssl/lib/"
ENV SL_INSTALL_PATH="/usr/local/ssl"
ENV LD_LIBRARY_PATH="/usr/local/ssl/lib/"
ENV CPPFLAGS="-I/usr/local/ssl/include/ -I/usr/local/ssl/include/openssl/"

#Remove Previous Python
RUN rm -r /usr/local/python3.6;exit=0

#Build Python 3.6 from source
RUN cd /tmp/Python-3.6.0 && ./configure  --enable-shared --prefix=/usr/local/python3.6 && make && make install

#Copy Libpython3.6m.so.1.0 to system directories
#RUN cp /usr/local/python3.6/lib/libpython3.6m.so.1.0 /usr/lib/x86_64-linux-gnu/ && cp /usr/local/python3.6/lib/libpython3.6m.so.1.0 /lib/x86_64-linux-gnu/

RUN ln -s -f /usr/local/python3.6/bin/python3.6 /usr/bin/python
RUN ln -s -f /usr/local/python3.6/bin/pip3.6 /usr/bin/pip
RUN ln -s -f /usr/local/python3.6/bin/python3.6 /usr/bin/python3
RUN ln -s -f /usr/local/python3.6/bin/pip3.6 /usr/bin/pip3
RUN ln -s -f /usr/local/python3.6/include/python3.6m/ /usr/include/python3.6
RUN ln -s -f /usr/local/python3.6/include/python3.6m/ /usr/include/python3.6m
RUN ln -s -f /usr/local/python3.6/lib/python3.6/ /usr/lib/python3.6

RUN ln -s -f /usr/local/python3.6/lib/libpython3.6m.so.1.0 /usr/lib/x86_64-linux-gnu/libpython3.6m.so.1.0
RUN ln -s -f /usr/local/python3.6/lib/libpython3.6m.so /usr/lib/x86_64-linux-gnu/libpython3.6m.so

RUN ln -s -f /usr/local/ssl/lib/libssl.so /usr/lib/libssl.so
RUN ln -s -f /usr/local/ssl/lib/libcrypto.so /usr/lib/libcrypto.so