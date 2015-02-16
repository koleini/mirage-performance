# mirage-perf

A mirage network performance test script (http://github.com/mirage/mirage)

Test environment
----------------

Xen server with internet/network connection for the performance test script to download required packages, and for the traffic generator to request IP address from DHCP server.


To use
------

Run the following command on the Xen server:

```
sudo bash mir-perf.sh <library> [version]
```

```library``` is the name of mirage library for the performance test. For the first release, we only support ```mirage-net-xen```. In the above command, ```version``` is the version number (commit hash) of the library on the github. If version is not specified, the latest version of the library will be used. For instance, you can write:

```
sudo bash mir-perf.sh mirage-net-xen b06361d
```
or
```
sudo bash mir-perf.sh mirage-net-xen
```

Test configuration
------------------
###mirage-net-xen

For performance test of mirage-net-xen, mirage-perf automatically downloads mirage-net-xen, and pins it on opam. Test application that will use mirage-net-xen is "netif-forward" on mirage-skeleton repository. 

The script creates an Ubuntu-based image for traffic generation (traff-gen) with two interfaces: One interface (eth0) is connected to the unikernel through a Xen bridge (if1) in order to pump traffic, and the other (eth1) is connected to Xenbr0 so can be used by mirage-perf to send control instructions to the traffic generator.

You can specify packet sizes and packet rates for the performance test in files cfg/range-psz and cfg/range-pps. The script mir-perf uses pktgen for traffic generation. Based on packet sizes and rates defined by the user, it creates pktgen config files. Each traffic pattern (config) runs for 10 seconds, and mir-perf samples the rates on traff-gen and tap1 interfaces, and sends samples to a file called "stats".


* Important: in the current version, control interface of traff-gen (eth1) receives IP from DHCP server. Yet, finding IP from MAC (set in cfg/VIF) is not automated. You need to boot traff-gen once (disable deletion in cleanup.sh), find the IP address assigned, and set it in cfg/SERVERIP. DCHP offers the same IP to the VM in future requests.


```
 _________                 _________
|         | eth0     tap0 |         |tap1
|traff-gen|----       ----|Unikernel|----
|         |   |       |   |         |   |
-----------   |  if1  |   -----------   | if2
______|eth1___|_______|_________________|_____
      |       ---------                 -
      |           ^                     ^
Dom0  |           |_____________________|
      |            bmon Bandwith Monitor
      <- mir-perf -> 
                   
```

###Other libraries
To be added.

