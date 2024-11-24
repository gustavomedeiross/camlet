CREATE TABLE IF NOT EXISTS wallets (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    balance INTEGER NOT NULL CHECK(balance >= 0),
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS transactions (
    id TEXT PRIMARY KEY NOT NULL,
    amount INTEGER NOT NULL CHECK(amount >= 0),
    type TEXT CHECK(type IN ('transfer', 'deposit', 'withdrawal')) NOT NULL,
    sender_wallet_id TEXT,
    recipient_wallet_id TEXT,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(sender_wallet_id) REFERENCES wallets(id),
    FOREIGN KEY(recipient_wallet_id) REFERENCES wallets(id)
);

