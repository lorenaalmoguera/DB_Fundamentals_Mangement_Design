CREATE TABLE INGREDIENTS (
    id_ingredient INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    price_per_unit REAL NOT NULL CHECK (price_per_unit >= 0),
    unit TEXT NOT NULL CHECK (unit IN ('gram', 'kilogram', 'pound', 'ounce'))
);

CREATE TABLE DONUTS (
    id_donut INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    isGlutenFree BOOLEAN NOT NULL CHECK (isGlutenFree IN (0,1)),
    price_per_donut REAL NOT NULL CHECK (price_per_donut >= 0)
);

CREATE TABLE INGREDIENTS_IN_DONUTS (
    id_donut INTEGER,
    id_ingredient INTEGER,
    PRIMARY KEY(id_donut, id_ingredient),
    FOREIGN KEY(id_donut) REFERENCES DONUTS,
    FOREIGN KEY(id_ingredient) REFERENCES INGREDIENTS
);

CREATE TABLE ORDERS(
    id_order INTEGER PRIMARY KEY AUTOINCREMENT,
    id_customer INTEGER NOT NULL,
    FOREIGN KEY(id_customer) REFERENCES CUSTOMERS
);

CREATE TABLE ORDER_DETAILS(
    id_order INTEGER,
    id_donut INTEGER,
    quantity INTEGER NOT NULL CHECK(quantity > 0),
    PRIMARY KEY(id_order, id_donut),
    FOREIGN KEY(id_order) REFERENCES ORDERS,
    FOREIGN KEY(id_donut) REFERENCES DONUTS
);

CREATE TABLE CUSTOMERS(
    id_customer INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL
);
