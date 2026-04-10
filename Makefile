FENNEL := fennel
FFLAGS := --compile
FNL := fnl
LUA := lua
SRC := $(shell find $(FNL) -name '*.fnl')
OUT := $(patsubst $(FNL)/%.fnl,$(LUA)/%.lua,$(SRC))

.PHONY: all clean
.DEFAULT_GOAL := all

all: init.lua $(OUT)

init.lua: init.fnl
	$(FENNEL) $(FFLAGS) $< > $@

$(LUA)/%.lua: $(FNL)/%.fnl
	@mkdir -p $(@D)
	$(FENNEL) $(FFLAGS) $< > $@

clean:
	rm -f init.lua
	rm -rf $(LUA)
