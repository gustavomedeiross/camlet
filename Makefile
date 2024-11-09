DB_PATH = db.sqlite
MIGRATION_FILE = migrations/init.sql
SEED_FILE = seeds/seed.sql

app.run.watch:
	dune exec -w camlet

db.migrate:
	sqlite3 $(DB_PATH) < $(MIGRATION_FILE)

db.seed:
	sqlite3 $(DB_PATH) < $(SEED_FILE)

db.reset:
	@if [ -f db.sqlite ]; then rm db.sqlite; fi
	$(MAKE) db.migrate

tailwind.watch:
	tailwindcss -i ./assets/input.css -o ./assets/output.css --watch
