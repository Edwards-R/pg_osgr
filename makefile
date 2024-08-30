# Run `make` to build, then `make install` to install. Depending on your system, you might need to sudo the install

EXTENSION = pg_osgr
EXTVERSION = 1.1.0

# This looks for a target. If it can't find it, it makes it
DATA = $(EXTENSION)--$(EXTVERSION).sql

# This is a target
$(EXTENSION)--$(EXTVERSION).sql: \
	function/*.sql
		cat $^ > $@

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)