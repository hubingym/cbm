cbm:
	v -show_c_cmd -o cbm .

install:
	cp cbm /usr/local/bin

install_win:
	cp cbm C:/bin

clean:
	rm -f cbm cbm.exe .*.c fns.txt

.PHONY: cbm install install_win clean