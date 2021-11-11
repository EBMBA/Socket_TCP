#
# 'make'        build executable file 'main'
# 'make clean'  removes all .o and executable files
#

# define the C compiler to use
CC = gcc

# define any compile-time flags
CFLAGS	:= -Wall -Wextra -g

# define library paths in addition to /usr/lib
#   if I wanted to include libraries not in /usr/lib I'd specify
#   their path using -Lpath, something like:
LFLAGS =

# define output directory
OUTPUT	:= output

# define source directory
SRCSRV		:= src/srv/multisrv 
SRCCLIENT	:= src/client


# define include directory
INCLUDE	:= include

# define lib directory
LIB		:= lib


SERVER_MAIN	:= server
SERVER_SOURCEDIRS	:= $(shell find $(SRCSRV) -type d)

CLIENT_MAIN	:= client
CLIENT_SOURCEDIRS := $(shell find $(SRCCLIENT) -type d)

INCLUDEDIRS	:= #$(shell find $(INCLUDE) -type d)
LIBDIRS		:= #$(shell find $(LIB) -type d)

FIXPATH = $1
RM = rm -f
MD	:= mkdir -p


# define any directories containing header files other than /usr/include
INCLUDES	:= $(patsubst %,-I%, $(INCLUDEDIRS:%/=%))

# define the C libs
LIBS		:= $(patsubst %,-L%, $(LIBDIRS:%/=%))

# define the C source files
CLIENT_SOURCES		:= $(wildcard $(patsubst %,%/*.c, $(CLIENT_SOURCEDIRS)))
SERVER_SOURCES		:= $(wildcard $(patsubst %,%/*.c, $(SERVER_SOURCEDIRS)))

# define the C object files 
CLIENT_OBJECTS		:= $(CLIENT_SOURCES:.c=.o)
SERVER_OBJECTS		:= $(SERVER_SOURCES:.c=.o)

# define the C object files 
OBJECTS		:= $(SOURCES:.c=.o)

#
# The following part of the makefile is generic; it can be used to 
# build any executable just by changing the definitions above and by
# deleting dependencies appended to the file from 'make depend'
#

CLIENT_OUTPUTMAIN	:= $(call FIXPATH,$(OUTPUT)/$(CLIENT_MAIN))
SERVER_OUTPUTMAIN	:= $(call FIXPATH,$(OUTPUT)/$(SERVER_MAIN))

all: $(OUTPUT) $(MAIN)
	@echo Executing 'all' complete!

$(OUTPUT):
	$(MD) $(OUTPUT)

# Client compilation
$(CLIENT_MAIN): $(OUTPUT) $(CLIENT_OBJECTS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(CLIENT_OUTPUTMAIN) $(CLIENT_OBJECTS) $(LFLAGS) $(LIBS)



# Server compilation
$(SERVER_MAIN): $(OUTPUT) $(SERVER_OBJECTS)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(SERVER_OUTPUTMAIN) $(SERVER_OBJECTS) $(LFLAGS) $(LIBS)

# this is a suffix replacement rule for building .o's from .c's
# it uses automatic variables $<: the name of the prerequisite of
# the rule(a .c file) and $@: the name of the target of the rule (a .o file) 
# (see the gnu make manual section about automatic variables)
.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c $<  -o $@

.PHONY: clean
clean:
	$(RM) $(call FIXPATH,$(CLIENT_OBJECTS))
	$(RM) $(call FIXPATH,$(SERVER_OBJECTS))
	$(RM) -R $(OUTPUT)
	@echo Cleanup complete!

run: all
	timeout 2 ./$(SERVER_OUTPUTMAIN)&
	./$(CLIENT_OUTPUTMAIN)
	@echo Executing 'run: all' complete!
