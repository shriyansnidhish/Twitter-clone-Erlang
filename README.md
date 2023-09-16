# COP5615 - Distributed Operating Systems Principles - TwitterClone

This project aims to create a Twitter-like engine and web user interface which supports functionalities like register, subscribe, tweet, re-tweet, and search queries based on hashtags and profiles.

## Project Objective

The goal of this project is to construct an engine similar to Twitter, complete with a web interface. This engine will allow users to register, post tweets, and conduct searches. Alongside this, a client simulator will be created to replicate the behavior of thousands of users and evaluate the performance of the distributed engine. The project is divided into two milestones.

### Phase 1

In this phase, we will focus on building the backbone of the Twitter-like engine. We will develop a simulator engine that mimics the activities of various users. It will simulate typical user actions such as registering an account, subscribing to other users, posting tweets, and retweeting posts from other users.
Final report of phase 1 can be found at: Part 1/Report.pdf

### Phase 2

In this phase, we will incorporate WebSockets to furnish a web interface.

## Project Features

The application will have the following features:

- Register
- Send tweet (tweets can include hashtags, e.g., #topic, and mentions, e.g., @bestuser)
- Subscribe to user tweets
- Re-tweets
- Query tweets by the subscribed user
- Query tweets by Hashtag
- Query tweets by Mentions
- Display the new tweets by subscribed users live (without querying)

## Web GUI

<p><img width="187" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/1d34c83f-9944-41d7-a65e-9b52064ebf23" style="border:1px solid black"> &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;
<img width="194" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/cf1c3e47-95d1-4d76-8bb5-2de02c7d06a8" style="border:1px solid black">&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;
<img width="186" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/89ab6281-c85f-4325-bba5-bce403b496f9" style="border:1px solid black">&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;
 <br><em>Fig 1.: User Registration</em>
 &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp;<em>Fig 2.: User Dashboard</em>&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;&nbsp;<em>Fig 3.: Hashtag Search not exisitng</em></p>

 
<p><img width="192" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/95556c5c-7dc7-42d9-9e27-a324da59ce59" style="border:1px solid black">
&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; <img width="178" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/7d2115cc-6b34-4384-a056-f99863b6266c" style="border:1px solid black"> &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;
<img width="193" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/d71030ab-e3f0-4b59-bb64-bac4775859a8" style="border:1px solid black">
<br><em>Fig 4.: Subscribe</em>&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;
<em>Fig 5.:Successfull Hashtag Search</em>
 &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;<em>Fig 6.: Subdcribed Tweets</em>&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp;</p>

<p><img width="175" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/182f7288-7d32-479e-b9f8-9c024bbdcdfa" style="border:1px solid black">&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;
<img width="188" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/94033d26-4fae-4e6c-9954-31691596330a" style="border:1px solid black">&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;<img width="189" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/cb1e2167-e3dd-42d5-ad29-997fec639d87" style="border:1px solid black"> &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp;
<br><em>Fig 7.:New Tweet</em>&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;&nbsp;<em>Fig 8.: Re-tweet</em>&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp; &nbsp;&nbsp;<em>Fig 9.:Search Mentions</em></p>
<p> <img width="181" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/a8e23567-ab84-4da0-8a96-5752e0e3d1fb" style="border:1px solid black">&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;</br><em>Fig 10.:Search Subscribers</em></p>


## Technology Used

The project is implemented using the **Erlang** programming language.

## Installation and Execution

### Installation

#### Erlang (on Mac)

```shell
brew install erlang
```

#### Project Code: 

Download files


### Steps to Run the Project:
1. Extract the contents of the zip file.
2. Move to the relevant directory using the command cd and execute “make run”.
- Run the following in terminal
```
cd Twitter
make run
```
3. Navigate to http://localhost:8082 in the browser.

## Implementation
TwitterClone is a system modeled after Twitter's features, utilizing the Actor model approach. In this setup, each user profile is seen as a separate actor, known as the client. A central engine, acting as a server, manages the user profile names and their related process IDs. To effectively simulate Twitter's operations, a separate simulator engine has been created. This simulator imitates regular Twitter actions and activates backend functions of the client actors to emulate various activities. This tool is vital for gauging performance and expanding the Twitter engine by creating a vast user base quickly. Finally, this backend system is connected to a web interface, which employs websockets for message exchanges between the individual actors.

### What is the actor model?
The actor model is a programming approach designed for creating concurrent and distributed applications. Within this model, an actor is the core computational unit, holding its state, behavior, and communication methods. They can send messages to other actors asynchronously, process incoming messages, and adjust their internal state accordingly. Crucially, actors don't have direct access to each other's data or state; they only communicate through messages.

### What does actors do?
**1. Server Engine:**
<br>**Account Management:** One of its primary roles is to keep track of registered user accounts. This ensures that every user has a unique identity within the system.
<br>**Tweet Management:** The server engine maintains records of all tweets. This includes:
<br>**Hashtag Management:** Using a map data structure, it tracks all tweets associated with a particular hashtag. The key in this map is the hashtag, while the value is a list of tweets containing that hashtag, along with the username of the tweeter.
<br>**Mention Management:** Similarly, it manages mentions. A map is maintained where the key represents a particular mention, and the value is a list of tweets containing that mention, paired with the respective tweeter’s usernames.
<br>**Search Capability:** The server processes search queries from clients. Users can search for specific hashtags, mentions, or even general keywords in their feed.

<br>**2. Client:**
<br>**Tweeting:** Clients can create and broadcast tweets to their followers or the general public.
<br>**Retweeting:** They can also share or retweet other users' tweets.
<br>**Search:** Clients have the capability to initiate search requests. They can look for tweets based on hashtags, mentions, or even specific user's tweets.
<br>**Displaying Feed:** Clients can display their feed, showcasing tweets from accounts they follow.

<br>**3. Simulator:**
<br>**User Generation:** The simulator has the capability to create 'N' number of users, simulating a real-world scenario of multiple users joining the platform.
<br>**Activity Simulation:** The simulator emulates real-world user actions. This includes subscribing to other users, tweeting, retweeting, and performing searches. This is essential for testing the system's robustness and scalability.

<br>**4. Handler:**
<br>**Communication Facilitator:** For each client actor, a corresponding handler actor process is spawned. This handler is responsible for managing the communication between the frontend (what the user interacts with) and the backend (where data is processed and stored). This design ensures that client interactions are managed efficiently and without delay, providing a seamless user experience.
In essence, each actor/process has a distinct role, ensuring the system operates seamlessly. The Server Engine is the backbone, storing essential data, the Client represents the user, the Simulator helps in testing and scaling, and the Handler ensures smooth communication between the system's front and back ends.

### Websockets and Cowboy server
Websockets:The client typically sends an HTTP request to the server to initiate a WebSocket connection.
The WebSocket handshake is then completed by the server by sending a response with an HTTP header to start the WebSocket connection.
The WebSocket protocol messages can be sent asynchronously between the client and server once the connection has been made. We use a straightforward Erlang web server named cowboy to control the socket and the WebSocket protocol to interface the Erlang runtime system with WebSockets.

### 
<img width="468" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/b1f8f3ee-2486-4f33-9c69-24a6c7f20dc3">

Cowboy:
Cowboy is the name of the Erlang framework that is most frequently used to build web servers. It's pretty amazing to see what Cowboy accomplishes with such little code. Cowboy works in combination with Ranch (which is a socket worker pool for tcp protocols) and Cowlib (library for message processing). The process tree begins once your server has been established because Cowboy is meant to construct servers. The only process active in the standalone Cowboy app is cowboy clock. A typical method for launching a cowboy http server is as follows.
<br>
```
cowboy:start_http(http, 10, [{port, 80}], [{env, [{dispatch, Dispatch}]}]).
```
### Steps to create and run a cowboy application on a Mac device.
• First, let's create the directory for our application all in lowercase.
```
$ mkdir hello_erlang
$ cd hello_erlang
```
• Install erlang.mk: 
```
curl -O https://erlang.mk/erlang.mk
```
• Bootstrap the application : 
```
make -f erlang.mk bootstrap bootstrap-rel
```
• Run the application : 
```
make run
```
• Now, add cowboy to the existing dependencies(in Makefile)
<br>
<img width="427" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/93cb568e-245d-4ecf-8f62-2d160831258b">
<br>• Add Routing and listening in the <app name>_app.erl
<br>• Run the application : ```make run```
[For more references, check out the documentation](https://ninenines.eu/docs/en/cowboy/2.6/guide/getting_started/)



### Control Flow
<img width="468" alt="image" src="https://github.com/Namita-Namita/DOSP_Twitter_clone/assets/31967922/cef5e492-7ba4-4679-b26b-290109bc572b">


## Conclusions
A websocket interface for a twitter like engine is successfully implemented with an interactive user interface through which users can perform functionalities like
<br>• Tweet
<br>• Register
<br>• Subscribe
<br>• Retweet
<br>• Query tweets by mention, hashtag & by subscribed users A websocket connection is established after registering and redirected to /name/main. Once a user tweeted, all the subscribed users will instantly get in the feed through websockets without any user interaction.

## Demo Video
Link: https://drive.google.com/file/d/1b7IjhklJRBHUPl5Cvqjj0Zj0tKpHZgw3/view?usp=share_link
