task: main.o container.o transport.o rand.o plane.o ship.o train.o time.o
	gcc -g -o task main.o container.o transport.o rand.o plane.o ship.o train.o time.o -no-pie
main.o: main.asm macros.inc
	nasm -f elf64 -g -F dwarf main.asm -l main.lst
container.o: container.asm
	nasm -f elf64 -g -F dwarf container.asm -l container.lst
transport.o: transport.asm
	nasm -f elf64 -g -F dwarf transport.asm -l transport.lst
rand.o: rand.asm
	nasm -f elf64 -g -F dwarf rand.asm -l rand.lst
plane.o: plane.asm
	nasm -f elf64 -g -F dwarf plane.asm -l plane.lst
ship.o: ship.asm
	nasm -f elf64 -g -F dwarf ship.asm -l ship.lst
train.o: train.asm
	nasm -f elf64 -g -F dwarf train.asm -l train.lst
time.o: time.asm
	nasm -f elf64 -g -F dwarf time.asm -l train.lst
