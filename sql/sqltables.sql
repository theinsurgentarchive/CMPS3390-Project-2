CREATE TABLE IF NOT EXISTS player (
    id INTEGER,
    name VARCHAR(32) UNIQUE NOT NULL,
    PRIMARY KEY(id AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS leaderboard (
    id INTEGER UNIQUE NOT NULL,
    score INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (id) REFERENCES player(id)
);

CREATE TABLE IF NOT EXISTS weapon (
    id INTEGER,
    name VARCHAR(32) UNIQUE NOT NULL,
    damage REAL NOT NULL DEFAULT 1.0,
    speed REAL NOT NULL DEFAULT 300.0,
    idle_anim VARCHAR(64) NOT NULL,
    fire_anim VARCHAR(64) NOT NULL,
    PRIMARY KEY(id AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS enemy (
    id INTEGER,
    name VARCHAR(32) UNIQUE NOT NULL,
    sprite VARCHAR(128) NOT NULL,
    health REAL NOT NULL DEFAULT 3.0,
    damage REAL NOT NULL DEFAULT 1.0,
    speed REAL NOT NULL DEFAULT 300.0,
    worth INTEGER NOT NULL DEFAULT 100,
    behavior INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY(id AUTOINCREMENT)
);

INSERT OR IGNORE INTO weapon(name, damage, speed, idle_anim, fire_anim) VALUES
('none', 0.0, 0.0, 'None', 'None'),
('guns', 1.0, 500.0, "Guns_idle", "Gun_fire"),
('railgun', 40, 1500.0, "Railgun_idle", "Railgun_fire"),
('rockets', 10.0, 300.0, "Rockets_idle", "Rockets_fire");

INSERT OR IGNORE INTO enemy(name, sprite, health, damage, speed, worth, behavior)
VALUES
('default', 'res://Resources/Fodder.tres', 3.0, 1.0, 150.0, 100, 0),
('orbiter', 'res://Resources/Orbiter.tres', 15.0, 5.0, 100.0, 500, 1);