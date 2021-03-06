FROM ubuntu:latest
MAINTAINER Cesare Tinelli <cesare-tinelli@uiowa.edu>

# Install everything we're gonna need.
RUN apt-get -y -qq update
RUN apt-get -y -qq install apt-utils wget tar
RUN apt-get -y -qq install git
RUN apt-get -y -qq install pkg-config libtool automake autoconf
RUN apt-get -y -qq install build-essential m4 software-properties-common
RUN apt-get -y -qq install aspcud unzip
RUN apt-get -y -qq install ocaml
RUN apt-get -y -qq install default-jre default-jdk

# Retrieve z3 binary.
RUN wget -qq https://github.com/Z3Prover/z3/releases/download/z3-4.4.1/z3-4.4.1-x64-ubuntu-14.04.zip
RUN unzip z3-4.4.1-x64-ubuntu-14.04.zip
RUN mv z3-4.4.1-x64-ubuntu-14.04/bin/z3 bin/.
RUN rm -rf z3-4.4.1-x64-ubuntu-14.04.zip z3-4.4.1-x64-ubuntu-14.04/

# Retrieve cvc4 binary
# RUN wget -qq http://cvc4.cs.nyu.edu/cvc4-builds/x86_64-linux-opt-proofs/unstable/cvc4-2016-11-03-x86_64-linux-opt-proofs
# RUN mv cvc4-2016-11-03-x86_64-linux-opt-proofs cvc4

# Retrieve opam.
RUN wget -qq https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin
RUN echo "y" | opam init
RUN eval $(opam config env)
RUN opam update
RUN opam switch 4.04.0

# Install ocaml packages needed for Kind 2
RUN echo "y" | opam install ocamlfind camlp4 menhir
RUN echo "y" | opam init && eval $(opam config env) && opam switch reinstall system
RUN eval $(opam config env)

# Force to use opam version of ocamlc.
ENV PATH="/root/.opam/4.04.0/bin:${PATH}"

# Certification stuff
# Retrieve jkind.
RUN wget -qq https://github.com/agacek/jkind/releases/download/v3.0.2/jkind-v3.0.2.zip
RUN unzip jkind-v3.0.2.zip && rm jkind-v3.0.2.zip
RUN mv jkind jkind-dir && mv jkind-dir/jkind jkind-dir/*.jar bin/. && chmod a+x bin/jkind && rm -rf jkind-dir
RUN chmod a+x bin/jkind*

# Latest proof-producing cvc4.
COPY ./docker_scripts/latest_proof_cvc4.sh .
RUN ls
RUN ./latest_proof_cvc4.sh
RUN mv cvc4 bin/cvc4
RUN chmod a+x bin/cvc4

# Retrieve and build Kind 2.
RUN mkdir kind2
COPY . kind2/
WORKDIR kind2
RUN if [ -f "Makefile" ] ; then make clean && rm -rf src/_build configure Makefile && rm -rf bin && rm -rf src/Makefile src/kind2.native && autoreconf ; fi
RUN ./autogen.sh
RUN ./build.sh
WORKDIR ./..
# Move Kind 2 binary to top level.
RUN mv kind2/bin/kind2 kind2-bin && rm -rf kind2 && mv kind2-bin kind2

# Entry point.
ENTRYPOINT ["./kind2"]
