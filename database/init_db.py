from pathlib import Path

from database.connection import DEFAULT_DB_PATH, Database

SCHEMA_PATH = Path(__file__).with_name("schema.sql")


def initialize(db: Database) -> None:
    script = SCHEMA_PATH.read_text(encoding="utf-8")
    with db.connection() as conn:
        conn.executescript(script)


if __name__ == "__main__":
    initialize(Database(DEFAULT_DB_PATH))
    print(f"Database ready at {DEFAULT_DB_PATH}")
