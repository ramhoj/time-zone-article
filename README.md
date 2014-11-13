Rails provides great tools for working with time zones but there's still a lot of things that can go wrong. This blog post aims to shed some light on these gotchas and provide solutions to the most common problems.

The one that probably has tricked me the most times is the fact that Rails fools you to believe it got you all covered all the time (pardon the pun). Don't get me wrong. I want Rails to do as much work for me as possible. But I've learnt the hard way that I can't get away with not knowing when and how Rails is helping me. Another gotcha is the fact that you have more time zones in play than you might first believe. Consider the following: db, server, dev machine, system configured, user specific configured and the browser.

## Configure your Rails app

So what tools do we have at our disposal as Rails developers? The most important one is the `config.time_zone` configuration in your `config/application.rb` file. ActiveRecord will help you convert from and to (which the documentation fails to explain) UTC and the time zone of your choice. This means that if all you're doing is having users post times through a form and use Active Record to persist it you're good to go.

## Processing time information

So what about actually doing something with the time information before persisting it? That's when it becomes tricky.

### Parsing

When parsing time information it's important to never do it without specifying the time zone. The best way to do this is to use `Time.zone.parse` (which will use the time zone specified in `config.time_zone`) instead of just `Time.parse` (which will use the computer's time zone).

### Work with Numerical and ActiveRecord attributes

Method calls like `2.hours.ago` uses the time zone you've configured, so use these if you can! The same thing is true for time attributes on ActiveRecord models.

    post = Post.first
    post.published_at #=> Thu, 22 Mar 2012 00:00:00 CDT -05:00

ActiveRecord fetches the UTC time from the database and converts it to the time zone in `config.time_zone` for you.

### Date vs Time

Time has date information but `Date` does NOT have time information. Even if you don't think you care you might realize that you do sooner then later. Be safe and use `Time` (or `DateTime` if you need support for times very far from the present).

But let's say you're stuck with a Date that you need to treat as a Time, at least make sure to convert it to your configured time zone:

    1.day.from_now # => Fri, 03 Mar 2012 22:04:47 JST +09:00
    Date.today.in_time_zone # => Fri, 02 Mar 2012 00:00:00 JST +09:00

Never use:

    Date.today.to_time # => 2012-03-02 00:00:00 +0100

## Querying

Since Rails know that your time information is stored as UTC in the database it will convert any time you give it to UTC.

    Post.where(["posts.published_at > ?", Time.current])

Just be sure to never construct the query string by hand and always use Time.current as the base and you should be safe.

## Working with APIs

### Supplying

Building a web API for others to consume? Make sure to always send all time data as UTC (and specify that this is the case).

    Time.current.utc.iso8601 #=> "2012-03-16T14:55:33Z"

Read more about why iso8601 is advisable here: [http://devblog.avdi.org/2009/10/25/iso8601-dates-in-ruby/](http://devblog.avdi.org/2009/10/25/iso8601-dates-in-ruby/)

### Consuming

When you get the time information from an external API which you don't have control over you simply need to figure out the format and time zone it's sent to you with. Because Time.zone.parse might not work with the format you receive you might need to use:

    Time.strptime(time_string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone

This assumes time_string a iso8601 formated string. `strptime` will throw a very unintuitive error complaining on the format argument when in reality the problem is that the time string's format mismatches the format template argument. `in_time_zone` defaults to use the Rails configured time zone.

Why there's no `strptime` method on `Time.zone` when there's a `parse` beats me.

## Working with multiple user time zones

Many systems needs to support users entering and viewing time information in a variety of time zones. To achieve this you need to store each user's time zone (probably just one of the time zone string names found in `rake time:zones:all`). Then to actually use that time zone the most common pattern is to simply create a private method in your ActionController and run it as an around filter.

    around_filter :user_time_zone, :if => :current_user

    def user_time_zone(&block)
      Time.use_zone(current_user.time_zone, &block)
    end

This will do the same thing as `config.time_zone` but on a per request basis. I still recommend to change the default `config.time_zone` to a time zone that is a good default for your users. (Thank you Matt Bridges for pointing out the potential problems with using a before_filter instead of an around_filter.)

## Testing

All the above is something that your tests should catch for you. The problem is that you as the user and your computer as the development server happen to reside in the same time zone. This is rarely the case once you push things to production.

There is [Zonebie](https://github.com/alindeman/zonebie), a gem that helps you deal with this. I haven't had time to try it out myself yet, but it looks promising. If you find this to be overkill, at least make sure that your tests run with `Time.zone` set to another time zone than the one your development machine is in!

## Cheat Sheet

### DOs

    2.hours.ago # => Fri, 02 Mar 2012 20:04:47 JST +09:00
    1.day.from_now # => Fri, 03 Mar 2012 22:04:47 JST +09:00
    Date.today.in_time_zone # => Fri, 02 Mar 2012 22:04:47 JST +09:00
    Date.current # => Fri, 02 Mar
    Time.zone.parse("2012-03-02 16:05:37") # => Fri, 02 Mar 2012 16:05:37 JST +09:00
    Time.zone.now # => Fri, 02 Mar 2012 22:04:47 JST +09:00
    Time.current # Same thing but shorter. (Thank you Lukas Sarnacki pointing this out.)
    Time.zone.today # If you really can't have a Time or DateTime for some reason
    Time.current.utc.iso8601 # When supliyng an API (you can actually skip .zone here, but I find it better to always use it, than miss it when it's needed)
    Time.strptime(time_string, "%Y-%m-%dT%H:%M:%S%z").in_time_zone # If you can't use time.zone.parse

### DON'Ts

    Time.now # => Returns system time and ignores your configured time zone.
    Time.parse("2012-03-02 16:05:37") # => Will assume time string given is in the system's time zone.
    Time.strptime(time_string, "%Y-%m-%dT%H:%M:%S%z") # Same problem as with Time#parse.
    Date.today # This could be yesterday or tomorrow depending on the machine's time zone.
    Date.today.to_time # => # Still not the configured time zone.

## Epilogue

I hope you've learned something from this post. I sure did while writing it! If you have any feedback on how it can be improved, or if you spot any errors, please let me know by posting a comment below!

## Ruby and Rails version

This article was first written in March 2012. Back then Rails 3.2 was the new hot and as you all know a lot happens in Rails-land in two and a half years and will continue to do so. I will do my best to keep the article accurate and up to date with the latest versions of Rails. If you spot anything that is reported deprecated or not working please let me know in the comment section below!

* Article publish date: **2012-03-20**
* Article last updated: **2014-11-04**
* Last verified Rails version: **4.1.7**
* Last verified Ruby version: **2.1.4p265**

There is a [git repository](https://github.com/ramhoj/time-zone-article) which you can clone:

    git clone git@github.com:ramhoj/time-zone-article.git
    cd time-zone-article
    bundle install
    rake db:create:all db:migrate db:test:prepare
    rspec spec/

The Rails application is running on the version defined above and has been verified to work under the described Ruby version above.
If you want to make sure things are working in the version of Rails or Ruby that you're using please fork the repository and make
the necessary adjustments and run the test suite. If you want more in-debt, hands-on of the examples this repository's test suite
aims to help with this too.

### Changelog

See the [git repository's commits](https://github.com/ramhoj/time-zone-article/commits/master).
