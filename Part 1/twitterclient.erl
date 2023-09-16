-module(twitterclient).

-export([tweet/3, userRegistration/4, retweet/3, subscribe/3, hashtagSearch/3,
         mentionSearch/3, tweetHandler/1]).

userRegistration(Username, Password, EmailId, ServerId) ->
    Pid = spawn(client, msg_handler, [#{}]),

    ProfilePid = #{"server" => ServerId},
    CurrentProfileUsername = maps:put("username", Username, ProfilePid),
    CurrentProfilePassword = maps:put("password", Password, CurrentProfileUsername),
    CurrentProfileEmailId = maps:put("email", EmailId, CurrentProfilePassword),
    CurrentProfileTweetList = maps:put("tweets", [], CurrentProfileEmailId),
    CurrentProfileSubscriptions = maps:put("subscriptions", [], CurrentProfileTweetList),
    CurrentProfileFeed = maps:put("feed", [], CurrentProfileSubscriptions),
    CurrentProfileId = maps:put("id", Pid, CurrentProfileFeed),

    Pid ! {start, CurrentProfileId},
    ServerId ! {add_profile, Username, CurrentProfileId}.

tweetHandler(UserProfileMap) ->
    Size = maps:size(UserProfileMap),
    if Size > 0 ->
           maps:get("server", UserProfileMap)
           ! {add_profile, maps:get("username", UserProfileMap), UserProfileMap};
       true ->
           ok
    end,
    receive
        {subscribe, ProfileToBeSubscribed} ->
            ProfileSubscribed = maps:get("subscriptions", UserProfileMap),
            NewProfileSubscriptionList = lists:append([ProfileToBeSubscribed], ProfileSubscribed),
            UpdatedProfile = maps:put("subscriptions", NewProfileSubscriptionList, UserProfileMap),
            tweetHandler(UpdatedProfile);
        {feed, Tweet} ->
            UserFeed = maps:get("feed", UserProfileMap),
            NewTweet = lists:append(UserFeed, [Tweet]),
            UpdatedProfile = maps:put("feed", NewTweet, UserProfileMap),
            tweetHandler(UpdatedProfile);
        {search_by_hashtag, Hashtag, UserTweets} ->
            io:fwrite("~p:Hashtag Searches  ~p are ~p ~n",
                      [maps:get("username", UserProfileMap), Hashtag, UserTweets]),
            io:fwrite("~p ~n", [twitterhandler:get_timestamp()]),
            tweetHandler(UserProfileMap);
        {search_by_mention, Mention, UserTweets} ->
            io:fwrite("~p:Mentions Searches ~p are ~p ~n",
                      [maps:get("username", UserProfileMap), Mention, UserTweets]),
            io:fwrite("~p ~n", [twitterhandler:get_timestamp()]),
            tweetHandler(UserProfileMap);
        {tweet, Tweet} ->
            TweetStringSplit = string:split(Tweet, " ", all),
            twitterhandler:extractHashtagsFromTweets(TweetStringSplit,
                                               1,
                                               maps:get("server", UserProfileMap),
                                               Tweet),
            Mentions =
            twitterhandler:extractMentionsFromTweets(TweetStringSplit,
                                                   1,
                                                   maps:get("server", UserProfileMap),
                                                   [],
                                                   Tweet),
            UserTweets = maps:get("tweets", UserProfileMap),
            NewTweet = lists:append(UserTweets, [Tweet]),
            UpdatedProfile = maps:put("tweets", NewTweet, UserProfileMap),
            MentionAndSubscriptionList =
                lists:append(Mentions, maps:get("subscriptions", UserProfileMap)),
                twitterhandler:handleTweetToSubscribe(MentionAndSubscriptionList,
                                                      1,
                                                      Tweet,
                                                      maps:get("server", UserProfileMap)),
            io:fwrite("~p:Tweet Added ~n", [maps:get("username", UserProfileMap)]),
            tweetHandler(UpdatedProfile);
        {start, Profile} ->
            tweetHandler(Profile)
    end.

subscribe(FirstUsername, SecondUsername, ServerId) ->
    ServerId ! {subscribe, FirstUsername, SecondUsername}.

hashtagSearch(Username, Hashtag, ServerId) ->
    io:fwrite("Searching start time ~n ------ ~n ~p ~n", [twitterhandler:get_timestamp()]),
    ServerId ! {search_by_hashtag, Username, Hashtag}.

mentionSearch(Username, Hashtag, Server_Id) ->
    io:fwrite("Searching start time ------- ~n ~p ~n", [twitterhandler:get_timestamp()]),
    Server_Id ! {search_by_mention, Username, Hashtag}.

tweet(Username, TweetString, ServerId) ->
    io:fwrite("----------------------------Start time: ~n ~p ~n--------------------"
              "-----",
              [twitterhandler:get_timestamp()]),
    ServerId ! {tweet, Username, TweetString}.

retweet(Username, Tweet, ServerId) ->
    io:fwrite("retweet Start time ~n ~p ~n", [twitterhandler:get_timestamp()]),
    ServerId ! {retweet, Username, Tweet}.
