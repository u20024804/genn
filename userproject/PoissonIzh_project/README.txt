
  Izhikevich network receiving Poisson input spike trains
  =======================================================

This example project contains a helper executable called "generate_run", which also
prepares additional synapse connectivity and input pattern data, before compiling and
executing the model. To compile it, simply type:
  nmake /f WINmakefile
for Windows users, or:
  make
for Linux, Mac and other UNIX users. 


  USAGE
  -----

  ./generate_run [CPU/GPU] [nPoisson] [nIzhikevich] [pConn] [gscale] [DIR] [MODEL] [DEBUG OFF/ON]

An example invocation of generate_run is:

  ./generate_run 1 100 10 0.5 2 outdir PoissonIzh 0

This will generate a network of 100 Poisson neurons connected to 10 Izhikevich neurons
with a 0.4 probability. The same network with sparse connectivity can be used by addind
the synapse population with sparse connectivity in PoissonIzh.cc and by uncommenting
the lines following the "//SPARSE CONNECTIVITY" tag in PoissonIzh.cu.