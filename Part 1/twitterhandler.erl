-module(twitterhandler).

-export([extractHashtagsFromTweets/4, extractMentionsFromTweets/5,
         handleTweetToSubscribe/4,fetchusernames/3,get_timestamp/0]).
-export([signInUser/0]).
-export([signOutUser/0]).

extractMentionsFromTweets(TweetsSubstring, Index, ServerId, ListOfTweets, FullTweetString) ->
    if Index > length(TweetsSubstring) ->
           ListOfTweets;
       true ->
           TweetSubstring = lists:nth(Index, TweetsSubstring),
           BooleanVar = string:equal("@", string:sub_string(TweetSubstring, 1, 1)),
           if BooleanVar ->
                  ServerId ! {update_mention_mapping, TweetSubstring, FullTweetString},
                  NewListOfTweets = lists:append(ListOfTweets, [string:sub_string(TweetSubstring, 2)]),
                  extractMentionsFromTweets(TweetsSubstring, Index + 1, ServerId, NewListOfTweets, FullTweetString);
              true ->
                  extractMentionsFromTweets(TweetsSubstring, Index + 1, ServerId, ListOfTweets, FullTweetString)
           end
    end.

extractHashtagsFromTweets(TweetsSubstring, Index, ServerId, FullTweetString) ->
    if Index > length(TweetsSubstring) ->
           ok;
       true ->
           TweetSubstring = lists:nth(Index, TweetsSubstring),
           BooleanVariable = string:equal("#", string:sub_string(TweetSubstring, 1, 1)),
           if BooleanVariable ->
                  ServerId ! {update_hashtag_mapping, TweetSubstring, FullTweetString},
                  extractHashtagsFromTweets(TweetsSubstring, Index + 1, ServerId, FullTweetString);
              true ->
                  extractHashtagsFromTweets(TweetsSubstring, Index + 1, ServerId, FullTweetString)
           end
    end.

fetchusernames(0,UsersList,_)->
    UsersList;
fetchusernames(NumberOfUsers,ListOfUsers,ServerId)->
    CharacterAllowed = "abcdefghijklmnopqrstuvwxyz",
    RandomString = get_random_string(10, CharacterAllowed),
    ExtractedUserBooleanVar = lists:any(fun(E)->E==RandomString end,ListOfUsers),
    if ExtractedUserBooleanVar->
        fetchusernames(NumberOfUsers, ListOfUsers,ServerId);
        true->
            twitterclient:userRegistration(RandomString,RandomString,RandomString,ServerId),
            fetchusernames(NumberOfUsers-1, lists:append([RandomString],ListOfUsers),ServerId)
    end.
signInUser()->
    {ok,[UserName]}=io:fread("Enter Username","~ts"),
    {ok,[PassWord]}=io:fread("Enter Password","~ts"),
    ServerConnectionId=spawn(list_to_atom("twitterserver@sn0702"),twitterengine,signInBuffer,[]),
    persistent_term:put("ServerId", ServerConnectionId),
    register(receiveTweetFromUser,spawn(sendreceive,receiveTweetFromUser,[])),

    ServerConnectionId!{UserName,[PassWord,whereis(receiveTweetFromUser)],self()},   
    receive
        {Registered}->
            if
                Registered=="Signed In"->
                    persistent_term:put("UserName",UserName),
                    persistent_term:put("SignedIn",true);
                true->
                    persistent_term:put("SignedIn",false)      
            end,
            io:format("~s~n",[Registered])  
    end.
handleTweetToSubscribe(Subscriptions, IndexofTweetList, Tweet, ServerId) ->
    if IndexofTweetList > length(Subscriptions) ->
           ok;
       true ->
           ServerId ! {add_tweet_to_feed, lists:nth(IndexofTweetList, Subscriptions), Tweet},
           handleTweetToSubscribe(Subscriptions,IndexofTweetList+1,Tweet,ServerId)
    end.

signOutUser()->
    SignedIn=persistent_term:get("SignedIn"),
    if
        SignedIn==true-> 
            RemoteServerId=persistent_term:get("ServerId"),
            RemoteServerId!{[persistent_term:get("UserName"),self()],signOut},
            receive
                {Registered}->
                    persistent_term:erase("UserName"),
                    io:format("~s~n",[Registered])  
            end;
        true->
            io:format("You should sign in to start tweeting Call twitterclient:userRegistration() to complete signin~n")    
    end.      

get_random_string(Length, CharacterAllowed) ->
    List = lists:foldl(fun(_, Acc) ->
                       [lists:nth(
                            rand:uniform(length(CharacterAllowed)), CharacterAllowed)]
                       ++ Acc
                    end,
                    [],
                    lists:seq(1, Length)),
    List.
get_timestamp() ->
  {MegaSec, Sec, MicroSec} = os:timestamp(),
  (MegaSec*1000000 + Sec)*1000 + (MicroSec/1000).
