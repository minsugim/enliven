CREATE DATABASE enlivendb;
USE enlivendb;

CREATE TABLE IF NOT EXISTS users (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(255) NOT NULL UNIQUE,
    passhash BINARY(60) NOT NULL
);

CREATE TABLE IF NOT EXISTS collaborators (
    userid INT NOT NULL,
    playlistid INT NOT NULL,
    PRIMARY KEY (userid, playlistid)
);

CREATE TABLE IF NOT EXISTS playlists (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    creatorid INT NOT NULL,
    private BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS videos (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    videoid VARCHAR(255) NOT NULL,
    title VARCHAR(255),
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS playlists_videos (
    id INT NOT NULL AUTO_INCREMENT primary key,
    playlistid INT,
    videoid INT,
    userid INT,
    timeAdded TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE collaborators ADD FOREIGN KEY (userid) REFERENCES users(id);
ALTER TABLE collaborators ADD FOREIGN KEY (playlistid) REFERENCES playlists(id);

ALTER TABLE playlists ADD FOREIGN KEY (creatorid) REFERENCES users(id)
ALTER TABLE playlists_videos ADD FOREIGN KEY (playlistid) REFERENCES playlists(id);
ALTER TABLE playlists_videos ADD FOREIGN KEY (videoid) REFERENCES videos(id);
ALTER TABLE playlists_videos ADD FOREIGN KEY (userid) REFERENCES users(id);