DB_PATH = db.sqlite
MIGRATION_FILE = migrations/init.sql

migrate:
	sqlite3 $(DB_PATH) < $(MIGRATION_FILE)

db_reset:
	@if [ -f db.sqlite ]; then rm db.sqlite; fi
	$(MAKE) migrate
