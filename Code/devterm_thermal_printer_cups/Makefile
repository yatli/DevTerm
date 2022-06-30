CC = gcc 
BIN = rastertocpi

all:
	${CC} rastertocpi.c -o ${BIN} -I /usr/include `cups-config --cflags` `cups-config --image --libs`

debug:
	${CC} rastertocpi.c -o ${BIN} -DSAFEDEBUG -I /usr/include `cups-config --cflags` `cups-config --image --libs`

#sudo make -B install
install:
	systemctl stop cups
	install rastertocpi /usr/lib/cups/filter/
	mkdir -p /usr/share/cups/model/clockworkpi
	install -m 644 cpi58.ppd /usr/share/cups/model/clockworkpi/
	systemctl start cups
