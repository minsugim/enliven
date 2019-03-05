# enLIVEN

# INFO 441 Final Project Proposal

## Why & What
Friends and communities often want to create collaborative playlists for genres, bands, and artists they enjoy listening to. However, services like Spotify are limited in songs and services like YouTube make it difficult collaborate and create playlists with other users. With enLIVEN, music enthusiasts can easily create playlists of Youtube videos that include songs and artists not typically found on streaming services. They can also collaborate with others to create these playlists. enLIVEN will allow people to turn their bland playlists into immersive visual media experiences.

We wanted to create enLIVEN because we felt that it would be a fun and inviting way to bring people who share the same music taste together. Furthermore, music can often be enhanced through visual media, whether it be through music videos or live performances. We felt that this would be a great way to bring visual musical experiences to our audience.

## Architecture
![](https://i.imgur.com/i57gF6c.png)

## User Stories
| Priority | User                 | Description                                                          | Implementation                                                                                                                                                                                                                         |
|----------|----------------------|----------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| P0       | As a user            | I want to view public playlists and play them.                       | Upon receiving a GET request to /v1/playlists the playlist microservice shows a list of public playlists to the user. Users will be able to click on these on the client and play the videos on them.                                                                                                                   |
| P0       | As a registered user | I want to be able to create a playlist.                              | Upon receiving a POST request to /v1/playlists the playlist microservice creates a new playlist and inserts it into the playlist database                                                                                              |
| P0       | As a registered user | I want to create a collaborative playlist.                           | Upon receiving a POST request to /v1/playlists with the column `private` as `false` the playlist microservice creates a new playlist and inserts it into the playlist database                                                          |
| P0       | As a registered user | I want to be able to add songs to a collaborative playlist.          | Upon receiving a POST request to /v1/playlists/{id} the playlist microservice adds the new song to the playlist.                                                                                                                       |
| P1       | As a registered user | I want to see all of the playlists I created and playlists I follow. | Upon receiving a GET request to /v1/playlists/mine the playlist microservice shows a list of playlists user has created and followed (users are listed as collaborators on playlists they follow).                                                                                                  |
| P1       | As a registered user | I want to be able to search songs to add to a playlist.              | Upon receiving a GET request to /v1/songs?search={query} we send a request to the Youtube API under GET https://www.googleapis.com/youtube/v3/search with the matching query and return the top 10 results the user gets to pick from. |
| P1       | As a registered user | I want to delete my playlists.                                       | Upon receiving a DELETE request to /v1/playlist/{id} the playlist microservice will delete the specified playlist                                                                                                                      |
| P1       | As a user            | I want to create an account.                                         | Upon receiving a POST request to /v1/users the gateway creates a new user account and stores it in the user database.                                                                                                                  |
| P1       | As a registered user | I want to log into my account.                                       | Upon receiving a POST request to /v1/sessions the gateway verifies the user credentials and shows the available documents if successful.                                                                                               |
| P1       | As a user            | I want to see songs appear in playlists as they are added.           | Upon receiving a POST request to /v1/playlists/{id} the playlist microservice adds the new song to the playlist that is sent to the playlists queue and sent to the clients through websockets.                                        |
| P2       | As a registered user | I want to follow playlists.                                 | Upon receiving a POST request to /v1/playlists/{id}/users the service adds you to as a collaborator to the playlist. When a user follows a playlist, they become a collaborator.                                                                                                                  |
| P2       | As a registered user | I want to rename my playlists.                                       | Every time a client renames a playlist a PATCH request will be sent to v1/playlists/{id} which will update the name of the playlist. Users who aren’t the creator will not be able to this.                                            |
| P2       | As a registered user | I want to see the users collaborating on a playlist                  | Upon receiving a GET request to a collaborative playlist to /v1/playlists/{id}/users the playlist microservice shows a list of users who are collaborators on the playlist                                                             |
| P2       | As a user            | I want to be able to search playlists.                               | Upon receiving a GET request to /v1/playlists?search={query} the playlist microservice will return a list of playlists that match that query.                                                                                          |
## Client

## Distribution of Work
| Area                     | Owner   |
|--------------------------|---------|
| Client                   | Vanessa |
| API gateway              | Claire  |
| Playlists Service        | Minsu   |
| Users/Playlists Database | Vanessa |
| Users/Sessions           | Claire  |

## Database Schema
#### Users
    CREATE TABLE IF NOT EXISTS users (
        id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL UNIQUE,
        username VARCHAR(255) NOT NULL UNIQUE,
        passhash BINARY(60) NOT NULL
    );
#### Sessions 
Redis key-value store, associating session IDs with session stores, which include: session start time, user profile
#### Collaborators
    CREATE TABLE IF NOT EXISTS collaborators (
        userid INT NOT NULL,
        playlistid INT NOT NULL,
        PRIMARY KEY (userid, playlistid),
        FOREIGN KEY (userid) REFERENCES users(id),
        FOREIGN KEY (playlistid) REFERENCES playlists(id)
    );
#### Playlists
    CREATE TABLE IF NOT EXISTS playlists (
        id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description VARCHAR(255),
        creatorid INT NOT NULL,
        FOREIGN KEY (creatorid) REFERENCES users(id)
    );
#### Videos
    CREATE TABLE IF NOT EXISTS videos (
        id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        videoID VARCHAR(255) NOT NULL,
        title VARCHAR(255),
        description VARCHAR(255)
    );

#### Playlists_Videos
    CREATE TABLE IF NOT EXISTS playlists_videos (
	id INT NOT NULL AUTO_INCREMENT primary key,
	playlistID INT,
	videoID INT,
	userID INT,
	FOREIGN KEY (playlistID) REFERENCES Playlists(id),
	FOREIGN KEY (videoID) REFERENCES Video(id),
	FOREIGN KEY (userID) REFERENCES User(id),
	timeAdded TIMESTAMP
);


## API Reference
**GET /v1/playlists**  
Gets a list of all public playlists, as an array of playlist objects. User doesn’t have to be logged in to perform this action.
* 200: Successfully retrieved playlists.
* 500: Internal server error. 

**POST /v1/playlists**  
Creates a new playlist with a unique id, and responds with the newly created playlist.
* 201: Successfully created playlist.
* 401: No valid user present in the X-User header.
* 415: Content-Type not application/json.
* 500: internal server error.

**GET /v1/playlists?search={query}**  
Returns a list of playlists that match the query, searched against playlist titles.
* 200: Successfully retrieved playlists.
* 500: Internal server error.

**GET /v1/playlists/mine**  
Gets a list of playlists that the user (included in the X-User header) has created and followed/liked. 
* 200: Successfully retrieved playlists.
* 401: No valid user present in the X-User header
* 500: Internal server error. 

**GET /v1/songs?search={query}**  
Gets a list of 10 songs that best match the query by sending request to the Youtube API. 
* 200: Successfully retrieved songs.
* 401: No valid user present in the X-User header.
* 404: No results found from Youtube.
* 500: Internal server error. 

**GET /v1/playlists/{id}**  
Gets the playlist with the given ID and responds with it.
* 200: Successfully retrieved playlist.
* 401: No valid user present in the X-User header.
* 404: Playlist with ID does not exist.
* 403: Not authorized to view playlist.
* 500: internal server error.

**POST /v1/playlists/{id}**  
Adds song to the playlist given in id. The Content-Type header must be `application/json`. The request body is a json object with the field `song`. To be a valid `song`, it must be a valid youtube videoID.
* 201: Successfully added song to playlist.
* 401: No valid user present in the X-User header.
* 404: Song with videoID does not exist or is not a valid videoID.
* 404: Playlist with ID does not exist.
* 403: Not authorized to add to playlist.
* 415: Content-Type not application/json.
* 500: internal server error.

**PATCH /v1/playlists/{id}**  
Updates the playlist with the given id and given updated playlist as response. The request body should be of type `application/json`, with a `name` field containing the new title of playlist, and/or `description`.
* 201: Successfully updated playlist.
* 401: No valid user present in the X-User header.
* 404: Playlist with ID does not exist.
* 403: Not authorized to patch playlist.
* 415: Content-Type not application/json.
* 500: internal server error.

**DELETE /v1/playlists/{id}**  
Delete playlist specified by the id. Only playlist creators are allowed to delete the playlist.
* 200: Successfully deleted playlist.
* 401: No valid user present in the X-User header.
* 403: Request user is not the playlist creator.
* 404: Playlist with ID does not exist.
* 500: Internal server error. 

**GET /v1/playlists/{id}/users**  
Gets a list of user profile that are collaborators on the playlist. 
* 200: Successfully retrieved collaborators.
* 401: No valid user present in the X-User header.
* 400: The id parameter is not a valid playlist ID.
* 403: Not authorized to view playlist/members.
* 500: Internal server error.

**POST /v1/playlists/{id}/users**  
Adds user specified in json object field `id` as a collaborator on the playlist. 
* 200: Successfully added collaborator.
* 401: No valid user present in the X-User header. 
* 400: The id parameter is not a valid user ID.
* 403: Not authorized to be collaborator for this playlist.
* 415: Content-Type not application/json.
* 500: Internal server error.

**POST /v1/users**  
Creates a new user account. The Content-Type header must be `application/json`. The request body is a json object with the new user's `email`, `password`, `passwordConf`, and `username`. To be a valid new user, password and passwordConf must match, email must not be taken by another user, and username must also. A copy of the created user is sent as a response.
* 201: Successfully created user.
* 400: The request body is not a valid user.
* 415: Content-Type not application/json.
* 500: Internal server error.

**GET /v1/users/{id}**  
Gets a the user with the given id, or gets the currently logged in user if id is `me`. The user must be logged in to perform this action. A copy of the given user is sent as a response.
* 200: Successfully retrieved user.
* 400: The id parameter is not a valid user ID.
* 401: The user is not logged in.
* 500: Internal server error.

**PATCH /v1/users/{id}**  
Updates the display name of the user with the given id, or the currently logged in user if id is `me`. The Content-Type header must be `application/json`. The request body is a json object with the user's new username. The user must be logged in to perform this action, and can only perform it on themselves. A copy of the updated user is sent as a response.
* 200: Successfully edited user.
* 400: The id parameter is not a valid user ID, or the provided updates are not valid.
* 401: The user is not logged in.
* 403: Not authorized.
* 415: Content-Type not application/json.
* 500: Internal server error.

**POST /v1/sessions/{id}**  
Creates a new user session. The Content-Type header must be `application/json`. The request body is a json object, that has email and password if a registered user is logged in.
* 201: Successfully created session.
* 400: The request body is not valid.
* 401: The email/password combo given was incorrect.
* 415: Content-Type not application/json.
* 500: Internal server error.

**DELETE /v1/sessions/{id}**  
Ends a user session. The session ID must be mine. 
* 200: Successfully ended session.
* 403: The user is attempting to end another user's session.
* 500: Internal server error.


