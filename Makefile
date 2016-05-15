CC = gcc
CFLAGS = -fPIC
LDFLAGS = -shared
RM = rm -f
TARGET_LIB = tcp.so
CHEZ = scheme

CSRC = tcp.c
SSRC = main.ss

default: ${TARGET_LIB}

$(TARGET_LIB): $(CSRC)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(TARGET_LIB) $(CSRC)

run: $(TARGET_LIB) $(SSRC)
	$(CHEZ) --script $(SSRC)

clean:
	-${RM} ${TARGET_LIB}
