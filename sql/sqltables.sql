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
    start_speed REAL NOT NULL DEFAULT 0.0,
    speed REAL NOT NULL DEFAULT 300.0,
    cooldown REAL NOT NULL DEFAULT 0.0,
    idle_anim VARCHAR(64) NOT NULL,
    fire_anim VARCHAR(64) NOT NULL,
    projectile VARCHAR(64) NOT NULL,
    mods VARCHAR(64) NULL,
    PRIMARY KEY(id AUTOINCREMENT)
);

CREATE TABLE IF NOT EXISTS enemy (
    id INTEGER,
    name VARCHAR(32) UNIQUE NOT NULL,
    sprite VARCHAR(128) NOT NULL,
    health REAL NOT NULL DEFAULT 3.0,
    damage REAL NOT NULL DEFAULT 1.0,
    speed REAL NOT NULL DEFAULT 300.0,
    weight INTEGER NOT NULL DEFAULT 1,
    worth INTEGER NOT NULL DEFAULT 100,
    behavior INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY(id AUTOINCREMENT)
);

INSERT INTO weapon(
    name, damage, start_speed, speed, cooldown,
    idle_anim, fire_anim, projectile, mods
) VALUES
('guns', 1.0, 750.0, 275.0, 0.1, "Guns_idle", "Gun_fire", "Bullet", "null"),
('rockets', 10.0, 50.0, 300.0, 0.25, "Rockets_idle", "Rockets_fire", "Rocket", "Seeking"),
('railgun', 40, 2000.0, 1500.0, 2.5, "Railgun_idle", "Railgun_fire", "Slug", "Pierce,Large")
ON CONFLICT(name) DO NOTHING;

INSERT INTO enemy(
    name, sprite, health, damage, speed, weight, worth, behavior
) VALUES
('default', 'res://Resources/Fodder.tres', 3.0, 1.0, 150.0, 20, 100, 0),
('orbiter', 'res://Resources/Orbiter.tres', 15.0, 5.0, 100.0, 15, 500, 1)
ON CONFLICT(name) DO NOTHING;