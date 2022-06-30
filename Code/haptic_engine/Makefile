CC = gcc

CFLAGS  = -O0 -g -Wall
LDFLAGS = 
LIBS = -lwiringPi -lm -lpthread -lrt -lportmidi -lporttime

MAIN = devterm_haptic_engine.elf

SRCS = motor.c  devterm_haptic_engine.c  utils.c
OBJS = $(SRCS:.c=.o)

.PHONY: depend clean

all:    $(MAIN)
	@echo compile $(MAIN)

$(MAIN): $(OBJS) 
	$(CC) $(CFLAGS) $(INCLUDES) -o $(MAIN) $(OBJS) $(LFLAGS) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c $<  -o $@

clean:
	$(RM) *.o *~ $(MAIN)
        
install:	$(MAIN)
	install $(MAIN) /usr/local/bin/
	install -m644 etc/systemd/system/devterm-haptic-engine.service /etc/systemd/system/
	systemctl daemon-reload
