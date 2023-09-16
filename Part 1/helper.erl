-module(helper).

-export([extractHashtagsFromTweets/4, extractMentionsFromTweets/5,
         handleTweetToSubscribe/4,fetchusernames/3,get_timestamp/0]).

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
    RandomString = get_random_string(4, CharacterAllowed),
    ExtractedUserBooleanVar = lists:any(fun(E)->E==RandomString end,ListOfUsers),
    if ExtractedUserBooleanVar->
        fetchusernames(NumberOfUsers, ListOfUsers,ServerId);
        true->
            twitterclient:userRegistration(RandomString,RandomString,RandomString,ServerId),
            fetchusernames(NumberOfUsers-1, lists:append([RandomString],ListOfUsers),ServerId)
    end.
handleTweetToSubscribe(Subscriptions, IndexofTweetList, Tweet, ServerId) ->
    if IndexofTweetList > length(Subscriptions) ->
           ok;
       true ->
           ServerId ! {add_tweet_to_feed, lists:nth(IndexofTweetList, Subscriptions), Tweet},
           handleTweetToSubscribe(Subscriptions,IndexofTweetList+1,Tweet,ServerId)
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
