# -*- Makefile -*- for sdl

ifneq ($(findstring $(MAKEFLAGS),s),s)
ifndef V
        QUIET_CC       = @echo '   ' CC $@;
        QUIET_AR       = @echo '   ' AR $@;
        QUIET_RANLIB   = @echo '   ' RANLIB $@;
        QUIET_INSTALL  = @echo '   ' INSTALL $<;
        export V
endif
endif

uname_S := $(shell uname -s)

# Since Windows builds could be done with MinGW or Cygwin,
# set a TARGET_OS_WINDOWS flag when either shows up.
ifneq (,$(findstring MINGW,$(uname_S)))
TARGET_OS_WINDOWS := YesPlease
endif
ifneq (,$(findstring CYGWIN,$(uname_S)))
TARGET_OS_WINDOWS := YesPlease
endif

SDL_LIB = libSDL.a
SDLMAIN_LIB = libSDLmain.a
AR    ?= ar
CC    ?= gcc
RANLIB?= ranlib
RM    ?= rm -f

prefix ?= /usr/local
libdir := $(prefix)/lib
man3dir := $(prefix)/share/man/man3
includedir := $(prefix)/include/SDL

HEADERS = include/*.h

MAN3_PAGES = docs/man3/*.3

SDL_SOURCES = \
    src/*.c \
    src/audio/*.c \
    src/cdrom/*.c \
    src/cpuinfo/*.c \
    src/events/*.c \
    src/file/*.c \
    src/joystick/*.c \
    src/stdlib/*.c \
    src/thread/*.c \
    src/timer/*.c \
    src/video/*.c \
	src/audio/disk/*.c \
	src/audio/dummy/*.c \
	src/video/dummy/*.c \
	src/joystick/dummy/*.c \
	src/cdrom/dummy/*.c \
	src/timer/dummy/*.c \
	src/loadso/dummy/*.c

SDLMAIN_SOURCES =	

ifeq ($(uname_S),Darwin)
SDL_SOURCES += \
    src/audio/macosx/*.c \
    src/cdrom/macosx/*.c \
    src/loadso/macosx/*.c \
    src/thread/pthread/*.c \
    src/timer/unix/*.c \
    src/video/quartz/*.m

SDLMAIN_SOURCES += \
    src/main/macosx/*.m
endif

ifdef TARGET_OS_WINDOWS
SDL_SOURCES += \
	src/audio/windib/*.c \
    src/cdrom/win32/*.c \
    src/joystick/win32/*.c \
    src/loadso/win32/*.c \
    src/thread/win32/SDL*.c \
    src/timer/win32/*.c \
    src/video/wincommon/*.c \
    src/video/windib/*.c

SDLMAIN_SOURCES += \
    src/main/win32/*.c
endif

SDL_SOURCES := $(shell echo $(SDL_SOURCES))
SDLMAIN_SOURCES := $(shell echo $(SDLMAIN_SOURCES))
MAN3_PAGES := $(shell echo $(MAN3_PAGES))
HEADERS := $(shell echo $(HEADERS))

HEADERS_INST := $(patsubst include/%,$(includedir)/%,$(HEADERS))
MAN3_INST := $(patsubst docs/man3/%,$(man3dir)/%,$(MAN3_PAGES))
SDL_OBJECTS := $(patsubst %.c,%.o,$(SDL_SOURCES))
SDLMAIN_OBJECTS := $(patsubst %.c,%.o,$(SDLMAIN_SOURCES))

CFLAGS ?= -O2
CFLAGS += -I. -Iinclude -DNO_STDIO_REDIRECT

.PHONY: install

all: $(SDL_LIB) $(SDLMAIN_LIB)

$(includedir)/%.h: include/%.h
	-@if [ ! -d $(includedir)  ]; then mkdir -p $(includedir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

$(libdir)/%.a: %.a
	-@if [ ! -d $(libdir)  ]; then mkdir -p $(libdir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

$(man3dir)/%.3: docs/man3/%.3
	-@if [ ! -d $(man3dir)  ]; then mkdir -p $(man3dir); fi
	$(QUIET_INSTALL)cp $< $@
	@chmod 0644 $@

install: $(MAN3_INST) $(HEADERS_INST) $(libdir)/$(SDL_LIB) $(libdir)/$(SDLMAIN_LIB)

clean:
	$(RM) $(SDL_OBJECTS) $(SDLMAIN_OBJECTS) *.a

distclean: clean

$(SDL_LIB): $(SDL_OBJECTS)
	$(QUIET_AR)$(AR) rcu $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

$(SDLMAIN_LIB): $(SDLMAIN_OBJECTS)
	$(QUIET_AR)$(AR) rcu $@ $^
	$(QUIET_RANLIB)$(RANLIB) $@

%.o: %.c
	$(QUIET_CC)$(CC) $(CFLAGS) -o $@ -c $<
