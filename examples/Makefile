examples=\
	fib\
	hello

exe_examples=\
	hello

all:
	for dir in $(examples); do echo -- clean $$dir --; cbm -d $$dir clean; done
	for dir in $(examples); do echo -- build $$dir --; cbm -d $$dir build; done
	for dir in $(examples); do echo -- build $$dir --; cbm -d $$dir build; done
	for dir in $(exe_examples); do echo -- run $$dir --; cbm -d $$dir run; done

clean:

.PHONY: all clean