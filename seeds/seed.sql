-- accounts
INSERT INTO accounts VALUES ('2553ed59-7954-4321-9351-feb836b0c35f', 'Gustavo', CURRENT_TIMESTAMP);
INSERT INTO accounts VALUES ('7ab1d4d7-683c-43fc-8d9d-3e8bfa25082f', 'João', CURRENT_TIMESTAMP);

-- payments
INSERT INTO payments VALUES (
    'c3fd50ff-3ec5-4820-951e-1e1913667ebb',
    10000,
    '2553ed59-7954-4321-9351-feb836b0c35f',
    '7ab1d4d7-683c-43fc-8d9d-3e8bfa25082f',
    CURRENT_TIMESTAMP
);
