SOURCES=$(wildcard *.cc)
OBJECTS=$(SOURCES:.cc=.o)
BINS=$(SOURCES:.cc=)

CXXFLAGS=-g -O0 -std=gnu++17

all: $(BINS)

.PHONY: clean test

clean:
	$(RM) $(OBJECTS) $(BINS)

test: $(BINS)
	@./run-test.py
