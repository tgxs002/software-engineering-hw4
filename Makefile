CC = /usr/bin/gcc

#OPENGL LIBS FOR LINUX
GLLIB :=  
#OPENGL LIBS FOR MAC

#COMPILER FLAGS
CCFLAGS := -Ofast

#include directories
#should include gl.h glut.h etc...
INCDIR := -I/usr/include 
LDLIBS := 

TARGET = maxTweeter
OBJS = maxTweeter.o hw4.tab.o


all: $(TARGET)


$(TARGET): $(OBJS)
	$(CC)  $^ $(CCFLAGS) $(LDLIBS)  -o $@

%.o : %.c
	$(CC) $(CCFLAGS) -o $@ -c $(LDLIBS) $(INCDIR) $<

clean:
	rm -f $(OBJS) $(TARGET)

