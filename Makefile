CC=avr-gcc
AS=$(CC)
LD=$(CC)

CPU=atmega8
UISP=uisp -dprog=stk500 -dpart=atmega8 -dserial=/dev/avr
CFLAGS=-Wall -mmcu=$(CPU)
LDFLAGS=-mmcu=$(CPU) -Wl,-Map=n64_to_wii.map

OBJS=main.o n64.o

all: n64_to_wii.hex

clean:
	rm -f n64_to_wii.elf n64_to_wii.hex n64_to_wii.map $(OBJS)

n64_to_wii.elf: $(OBJS)
	$(LD) $(OBJS) $(LDFLAGS) -o n64_to_wii.elf

n64_to_wii.hex: n64_to_wii.elf
	avr-objcopy -j .data -j .text -O ihex n64_to_wii.elf n64_to_wii.hex
	avr-size n64_to_wii.elf

fuse:
	$(UISP) --wr_fuse_h=0xc9 --wr_fuse_l=0x9f

flash: n64_to_wii.hex
	$(UISP) --erase --upload --verify if=n64_to_wii.hex

%.o: %.S
	$(CC) $(CFLAGS) -c $<
