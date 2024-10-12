DB_PATH = db.sqlite
MIGRATION_FILE = migrations/init.sql

migrate:
	sqlite3 $(DB_PATH) < $(MIGRATION_FILE)
