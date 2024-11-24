CREATE TABLE IF NOT EXISTS accounts (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payments (
    id TEXT PRIMARY KEY NOT NULL,
    amount INTEGER NOT NULL CHECK(amount >= 0),
    sender_account_id TEXT NOT NULL,
    recipient_account_id TEXT NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(sender_account_id) REFERENCES accounts(id),
    FOREIGN KEY(recipient_account_id) REFERENCES accounts(id)
);

