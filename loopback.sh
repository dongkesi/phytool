#!/bin/sh

eth_dev=$1
phy_addr=$2
# digital mii pcs analog external far-end dump-base dump-ext dump-all
test_mode=$3

if [ $# != 3 ]
then
        echo $# parameters
        echo "usage: phytool <eth*> <phyaddr> <testmode>"
        echo "testmod: digital mii pcs analog external far-end dump-base dump-ext dump-all"
        exit
fi

# reg
read() {
        printf 'read addr 0x%04x: ' $1
        phytool read ${eth_dev}/${phy_addr}/$1
}

# reg val
write() {
        phytool write ${eth_dev}/${phy_addr}/$1 $2
}

# reg
read_ext() {
        phytool write ${eth_dev}/${phy_addr}/0x0d 0x001f
        phytool write ${eth_dev}/${phy_addr}/0x0e $1
        phytool write ${eth_dev}/${phy_addr}/0x0d 0x401f
        printf 'read extend addr 0x%04x: ' $1
        phytool read ${eth_dev}/${phy_addr}/0x0e
}

# reg val
write_ext() {
        phytool write ${eth_dev}/${phy_addr}/0x0d 0x001f
        phytool write ${eth_dev}/${phy_addr}/0x0e $1
        phytool write ${eth_dev}/${phy_addr}/0x0d 0x401f
        echo -n "extend register ${1} write ${2}: "
        phytool write ${eth_dev}/${phy_addr}/0x0e $2
}

dump_base() {
        for addr in {0..31}; do
                read $addr
        done
}

dump_ext() {
        read_ext 0x0025
        read_ext 0x002D
        read_ext 0x0031
        read_ext 0x0032
        read_ext 0x0033
        read_ext 0x0037
        read_ext 0x0043
        read_ext 0x0055
        read_ext 0x006e
        read_ext 0x006f
        read_ext 0x0071
        read_ext 0x0072
        read_ext 0x0086
        read_ext 0x00d3
        read_ext 0x00e9
        read_ext 0x00fe
        read_ext 0x0134
        read_ext 0x0135
        read_ext 0x0161
        read_ext 0x016f
        read_ext 0x0170
        read_ext 0x0172
        read_ext 0x0180
        read_ext 0x01A7
}

if [ $test_mode == "digital" ]
then
        echo "${test_mode} loopback test begin"
        write 0x001f 0x8000             # software reset
        read 0x001f
        write 0x0000 0x0140                     # force 1000BASE-T operation
        read 0x0000
        write 0x0016 0x0004                     # enable digital loopback
        read 0x0016
        write 0x001f 0x4000                     # apply a software restart
        echo "${test_mode} loopback test done"
fi

if [ $test_mode == "far-end" ]
then
        echo "${test_mode} loopback test begin"
        write 0x0016 0x0020             # enable reverse loopback
        read 0x0016
        write 0x001f 0x4000                     # apply a software restart
        #read 0x0016
        echo "${test_mode} loopback test done"
fi

if [ $test_mode == "dump-base" ]
then
        dump_base
fi

if [ $test_mode == "dump-ext" ]
then
        dump_ext
fi

if [ $test_mode == "dump-all" ]
then
        dump_base
        dump_ext
fi

