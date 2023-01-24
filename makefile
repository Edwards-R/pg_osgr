EXTENSION = osgr
EXTVERSION = 0.0.1

$(EXTENSION)--$(EXTVERSION).sql: \
accuracy.sql \
find_datum.sql \
ci_*.sql \
gb_*.sql \
ing_*.sql \
process_*.sql \
to_ci.sql \
to_gb.sql \
to_ing.sql \
to_gridref.sql
	cat $^ > $@