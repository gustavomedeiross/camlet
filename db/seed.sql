-- wallets
INSERT INTO wallets VALUES ('2553ed59-7954-4321-9351-feb836b0c35f', 'Gustavo', 100000000, CURRENT_TIMESTAMP);
INSERT INTO wallets VALUES ('7ab1d4d7-683c-43fc-8d9d-3e8bfa25082f', 'João', 100000000, CURRENT_TIMESTAMP);

-- transactions
INSERT INTO transactions VALUES (
    'c3fd50ff-3ec5-4820-951e-1e1913667ebb',
    10000,
    'transfer',
    '2553ed59-7954-4321-9351-feb836b0c35f',
    '7ab1d4d7-683c-43fc-8d9d-3e8bfa25082f',
    CURRENT_TIMESTAMP
);
