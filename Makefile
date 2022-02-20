all: build

build:
	@../sjasmplus/sjasmplus hello.asm --lst --raw=hello.bin
	@bin2hex hello.bin hello.hex

copy: build
	cpmrm -fz80pack-hd ../cpmsim/disks/drivei.dsk 4:hello.com
	cpmcp -fz80pack-hd ../cpmsim/disks/drivei.dsk hello.bin 4:hello.com

run:
	@cd .. && ./zob.sh

clean:
	@rm -f hello.bin hello.hex hello.lst
