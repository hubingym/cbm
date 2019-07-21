build:
	v -o cbm ./

install:
	cp cbm C:/bin

cbm-build:
	cbm -d ../qjs/quickjs build

cbm-clean:
	cbm -d ../qjs/quickjs clean
