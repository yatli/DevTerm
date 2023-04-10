CC = gcc

CFLAGS  = -O0 -g -Wall
LDFLAGS =
INCLUDES =
LIBS = -lwiringPi -lm -lpthread -lrt

MAIN = devterm_extcart_daemon.elf

SRCS = main.c
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
        

