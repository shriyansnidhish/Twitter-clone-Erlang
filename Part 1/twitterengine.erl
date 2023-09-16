-module(twitterengine).

-export([starttwitterserver/3, fetchserverid/0]).
-export([signInBuffer/0]).
-export([signInOut/0]).

fetchserverid() ->
    spawn(twitterengine, starttwitterserver, [#{}, #{}, #{}]).


signInBuffer()->
    receive
        % for SignIn
        {UserName,PasswordAndProcess,Pid}->
            userregister ! {UserName,PasswordAndProcess,self(),Pid};
        % for Registeration    
        {UserName,PassWord,Email,Pid,register}->
            userregister ! {UserName,PassWord,Email,self(),Pid};      
        {UserName,Tweet,Pid,tweet}->
            receiveTweet !{UserName,Tweet,self(),Pid};
        {UserName,Pid}->
            if 
                Pid==signOut->
                    [UserName1,RemoteNodePid]=UserName,
                    userProcessIdMap!{UserName1,RemoteNodePid,self(),randomShitAgain};
                true->
                 receiveTweet !{UserName,self(),Pid}
            end;     
        {Pid}->
            userregister ! {self(),Pid,"goodMorningMate"};    
        {UserName,CurrrentUserName,Pid,PidOfReceive}->
            subscribeToUser ! {UserName,CurrrentUserName,PidOfReceive,self(),Pid}
    end,
    receive
        {Message,Pid1}->
            Pid1 ! {Message},
            signInBuffer()        
    end.  
signInOut()->
    twitterhandler:signOutUser().    
starttwitterserver(MapUser, MapHashtags, MapMentions) ->
    receive
        {tweet, UpdateUsername, FullTweetString} ->
            UpdateProfile = maps:get(UpdateUsername, MapUser),
            Pid = maps:get("id", UpdateProfile),
            Pid ! {tweet, FullTweetString},
            starttwitterserver(MapUser, MapHashtags, MapMentions);
        {add_profile, UpdateUsername, UpdateProfile} ->
            UserMap = maps:put(UpdateUsername, UpdateProfile, MapUser),
            starttwitterserver(UserMap, MapHashtags, MapMentions);
        {subscribe, FirstUsername, SecondUsername} ->
            UserProfile = maps:get(SecondUsername, MapUser),
            UserProfilePid = maps:get("id", UserProfile),
            UserProfilePid ! {subscribe, FirstUsername},
            starttwitterserver(MapUser, MapHashtags, MapMentions);
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
            starttwitterserver(MapUser, MapHashtags, MapMentions);
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
            starttwitterserver(MapUser, MapHashtags, MapMentions);
        {add_tweet_to_feed, UpdateUsername, FullTweetString} ->
            BooleanVar = lists:any(fun(E) -> E == UpdateUsername end, maps:keys(MapUser)),
            if BooleanVar ->
                   UpdateProfile = maps:get(UpdateUsername, MapUser),
                   Pid = maps:get("id", UpdateProfile),
                   Pid ! {feed, FullTweetString},
                   starttwitterserver(MapUser, MapHashtags, MapMentions);
               true ->
                   io:fwrite("ohhhhhhhh, looks like user profile doesn't exists. ~n"),
                   starttwitterserver(MapUser, MapHashtags, MapMentions)
            end;
        {update, UpdateUsername, UpdateProfile} ->
            starttwitterserver(maps:put(UpdateUsername, UpdateProfile, MapUser),
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
                   starttwitterserver(MapUser, NewMentionString, MapMentions);
               true ->
                   NewMentionString = maps:put(MentionString, [FullTweetString], MapHashtags),
                   starttwitterserver(MapUser, NewMentionString, MapMentions)
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
            starttwitterserver(MapUser, MapHashtags, MapMentions);
        {update_mention_mapping, MentionString, FullTweetString} ->
            BooleanVar = maps:is_key(MentionString, MapMentions),
            if BooleanVar ->
                   StringFromMentionMap = maps:get(MentionString, MapMentions),
                   NewMentionString =
                       maps:put(MentionString,
                                lists:append(StringFromMentionMap, [FullTweetString]),
                                MapMentions),
                   starttwitterserver(MapUser, MapHashtags, NewMentionString);
               true ->
                   NewMentionString = maps:put(MentionString, [FullTweetString], MapMentions),
                   starttwitterserver(MapUser, MapHashtags, NewMentionString)
            end
    end.
