-module(twitter).

-export([start_twitter_server/3, fetch_server_id/0]).

fetch_server_id() ->
    spawn(twitter, start_twitter_server, [#{}, #{}, #{}]).

start_twitter_server(MapUser, MapHashtags, MapMentions) ->
    receive
        {tweet, UpdateUsername, FullTweetString} ->
            UpdateProfile = maps:get(UpdateUsername, MapUser),
            Pid = maps:get("id", UpdateProfile),
            Pid ! {tweet, FullTweetString},
            start_twitter_server(MapUser, MapHashtags, MapMentions);
        {add_profile, UpdateUsername, UpdateProfile} ->
            UserMap = maps:put(UpdateUsername, UpdateProfile, MapUser),
            start_twitter_server(UserMap, MapHashtags, MapMentions);
        {subscribe, FirstUsername, SecondUsername} ->
            UserProfile = maps:get(SecondUsername, MapUser),
            UserProfilePid = maps:get("id", UserProfile),
            UserProfilePid ! {subscribe, FirstUsername},
            start_twitter_server(MapUser, MapHashtags, MapMentions);
        {search_by_hashtag, UpdateUsername, Hashtag} ->
            UpdateProfile = maps:get(UpdateUsername, MapUser),
            Pid = maps:get("id", UpdateProfile),
            BooleanVar = maps:is_key(Hashtag, MapHashtags),
            if BooleanVar ->
                   Pid ! {search_by_hashtag, Hashtag, maps:get(Hashtag, MapHashtags)};
               true ->
                   io:fwrite("ohhhhhhhh, Looks like used hastag is incorrect/not found. Please "
                             "try again ~n"),
                   Pid ! {search_by_hashtag, Hashtag, []}
            end,
            start_twitter_server(MapUser, MapHashtags, MapMentions);
        {retweet, UpdateUsername, FullTweetString} ->
            UpdateProfile = maps:get(UpdateUsername, MapUser),
            Pid = maps:get("id", UpdateProfile),
            BooleanVariable = fun(E) -> E == FullTweetString end,
            SearchedTweet = lists:any(BooleanVariable, maps:get("feed", UpdateProfile)),
            if SearchedTweet == true ->
                   Pid ! {tweet, FullTweetString};
               true ->
                   io:fwrite("ohhhhhhhh noooo, tweet not found.~n"),
                   ok
            end,
            start_twitter_server(MapUser, MapHashtags, MapMentions);
        {add_tweet_to_feed, UpdateUsername, FullTweetString} ->
            BooleanVar = lists:any(fun(E) -> E == UpdateUsername end, maps:keys(MapUser)),
            if BooleanVar ->
                   UpdateProfile = maps:get(UpdateUsername, MapUser),
                   Pid = maps:get("id", UpdateProfile),
                   Pid ! {feed, FullTweetString},
                   start_twitter_server(MapUser, MapHashtags, MapMentions);
               true ->
                   io:fwrite("ohhhhhhhh, looks like user profile doesn't exists. ~n"),
                   start_twitter_server(MapUser, MapHashtags, MapMentions)
            end;
        {update, UpdateUsername, UpdateProfile} ->
            start_twitter_server(maps:put(UpdateUsername, UpdateProfile, MapUser),
                                 MapHashtags,
                                 MapMentions);
        {update_hashtag_mapping, MentionString, FullTweetString} ->
            BooleanVar = maps:is_key(MentionString, MapHashtags),
            if BooleanVar ->
                   StringFromMentionMap = maps:get(MentionString, MapHashtags),
                   NewMentionString =
                       maps:put(MentionString,
                                lists:append(StringFromMentionMap, [FullTweetString]),
                                MapHashtags),
                   start_twitter_server(MapUser, NewMentionString, MapMentions);
               true ->
                   NewMentionString = maps:put(MentionString, [FullTweetString], MapHashtags),
                   start_twitter_server(MapUser, NewMentionString, MapMentions)
            end;
        {search_by_mention, UpdateUsername, Mention} ->
            UpdateProfile = maps:get(UpdateUsername, MapUser),
            Pid = maps:get("id", UpdateProfile),
            io:fwrite("~p ~n", [MapMentions]),
            BooleanVar = maps:is_key(Mention, MapMentions),
            if BooleanVar ->
                   Pid ! {search_by_mention, Mention, maps:get(Mention, MapMentions)};
               true ->
                   io:fwrite("ohhhhhhhh, looks like the user you searched doesn't exist. ~n"),
                   Pid ! {search_by_mention, Mention, []}
            end,
            start_twitter_server(MapUser, MapHashtags, MapMentions);
        {update_mention_mapping, MentionString, FullTweetString} ->
            BooleanVar = maps:is_key(MentionString, MapMentions),
            if BooleanVar ->
                   StringFromMentionMap = maps:get(MentionString, MapMentions),
                   NewMentionString =
                       maps:put(MentionString,
                                lists:append(StringFromMentionMap, [FullTweetString]),
                                MapMentions),
                   start_twitter_server(MapUser, MapHashtags, NewMentionString);
               true ->
                   NewMentionString = maps:put(MentionString, [FullTweetString], MapMentions),
                   start_twitter_server(MapUser, MapHashtags, NewMentionString)
            end
    end.
