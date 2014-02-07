CC=gcc
CFLAGS=-c -Wall
LDFLAGS=
SOURCES=histeq.c main.c octave.c timer.c xmalloc.c
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=histeq

all: $(SOURCES) $(EXECUTABLE)
	
$(EXECUTABLE): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.cpp.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -rf *.o $(EXECUTABLE) histeq_output*


