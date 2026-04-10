FENNEL := fennel
FFLAGS := --compile

FNL := fnl
LUA := lua

SRC := $(wildcard $(FNL)/*.fnl)
OUT := $(patsubst $(FNL)/%.fnl,$(LUA)/%.lua,$(SRC))

init.lua: init.fnl
	$(FENNEL) $(FFLAGS) $< > $@

$(LUA)/%.lua: $(FNL)/%.fnl
	@mkdir -p $(@D)
	$(FENNEL) $(FFLAGS) $< > $@

all: init.lua $(OUT)

clean:
	rm -f init.lua
	rm -rf $(LUA)
