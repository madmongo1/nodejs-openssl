# nodejs-openssl
A pseudo-library to allow cmake to find_package(OpenSSL) when linked with node (without linking to openssl)

When linking a shared library for node, openssl is already exported by the node executable.

This project builds a dummy library that allows find_package(OpenSSL) to find node's header files and some empty libraries.

You must set NODEJS_DEV_ROOT to point to the directory before the include directory in the node dev tree

e.g. ${HOME}/my-node-dev/node/6.9.1

