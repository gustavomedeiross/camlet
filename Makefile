# TODO: move this code to dune file later :)

DB_PATH = db/db.sqlite
INIT_FILE = db/init.sql
SEED_FILE = db/seed.sql

app.run.watch:
	dune exec -w camlet

db.init:
	sqlite3 $(DB_PATH) < $(INIT_FILE)

db.seed:
	sqlite3 $(DB_PATH) < $(SEED_FILE)

db.reset:
	@if [ -f $(DB_PATH) ]; then rm $(DB_PATH); fi
	$(MAKE) db.init

tailwind.watch:
	tailwindcss -c ./tailwind/tailwind.config.js -i ./tailwind/input.css -o ./static/output.css --watch
