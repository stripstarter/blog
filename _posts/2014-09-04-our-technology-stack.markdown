---
layout: post
title:  "Stripstarter takes off its clothes"
date:   2014-09-04 23:03:00
categories: stripstarter technology
---
# **Our Technology Stack**

[Stripstarter](http://stripstarter.us) is being built as a simple Ruby on Rails app, relying on rails to serve up HTML.  In fact at this point, while we do have some JSON-compatible endpoints, it is exclusively HTML-based with the exception of our search typeahead.  In this blog post I'd like to highlight the different technologies we've incorporated so far and what struggles we've run into with them.  Going through the closed [Github issues](http://github.com/stripstarter/stripstarter/issues?q=is%3Aissue+is%3Aclosed) in order should help me.

#### [RSpec](http://rspec.info)

Nothing too fancy here.  I switched us from Unit::Test to RSpec almost immediately.  Having never used Rails' built-in testing service, I have only heard that RSpec is better.

#### [Travis](http://travis-ci.org)

Travis is a continuous-integration service.  Every time we make a pull request, Travis:

* clones our repo (the service is free if we're open source!)
* installs our gems
* runs our test suite

My favorite part is the little box on our README which tells you if the build is currently passing or failing.  Travis even lets you integrate services such as Redis, MongoDB, RabbitMQ, and more.  Thanks, Travis!

#### [DigitalOcean](https://www.digitalocean.com/)

Lest I forget, our gracious hosts.  Right now we're only paying $5/month for a 512MB Ubuntu 14.04 server droplet.  Though with Sidekiq, Jekyll, Unicorn, and other constantly running processes, we're getting pretty close to our memory usage already.  Pretty soon, we'll need to upgrade to a 2GB RAM droplet.  Our services running in the background worth mentioning are:

* nginx - web server; routes traffic on port 80 to a UNIX socket shared with...
* [Unicorn](https://github.com/blog/517-unicorn) - application server
* [Jekyll](http://jekyllrb.com/) - this blog; nginx routes `blog.` subdomain requests to here
* [God](http://godrb.com/) (for jekyll)
* Monthly database backups

#### [Capistrano](https://github.com/capistrano/capistrano)

Deployments made easy.  We store our sensitive files on the server and it just creates a new symlink each deploy when it creates a newly versioned directory.  With the [capistrano-sidekiq gem](https://github.com/seuros/capistrano-sidekiq), we can use capistrano to start and stop sidekiq as well.

#### [Sidekiq](https://github.com/mperham/sidekiq)

Used for creating non-blocking background workers, apparently using the Celluloid actor framework.  That's as much as I know.  We're using this currently just for mailers, but it'd be nice to have it handle more time-consuming blocking procedures such as file upload.

#### [Paperclip](https://github.com/thoughtbot/paperclip) and Amazon S3

This ended up being a huge bitch to set up.  Way more than it should have been.  We've got an S3 bucket that needs to be US Standard (so Paperclip can infer its path) and for the love of god: don't rename your migration classes.  I did it.. and the deployment let the fact that it *didn't run the migration* to add Paperclip columns fail silently.  As a result, only in production was it telling me that there were undefined methods.  So being the idiot that I am, I used the first SO answer I found which was:

> make them attr_accessor

Well, turns out making getter/setter methods for `User#avatar_file_name` 1) overwrites the Paperclip methods, and 2) just covers up the underlying problem - that the migration never got ran on the production server.  At least the hours of bug hunting made me write (albeit fruitless) tests that really should have been written already.  Now we have tests to verify that avatars are being stored locally and uploaded to Amazon in mock-production mode.

#### [Soulmate](https://github.com/seatgeek/soulmate) and [Redis](http://redis.io)

In addition to being necessary for message queueing with Sidekiq, Redis is also used for the awesome search autocomplete gem Soulmate.  With a little configuration, we load all Campaigns and Performers into Redis as sorted sets of partially completed words.  The means if we have a performer named "Jane Smith", we can type in "Ja" and she'll pop up below the search box.

The most popular documentation for jQueryUI's autocomplete feature ended up being for a deprecated version, but eventually we were able to get a working search box in the navbar.  In the backend we just had to implement `#load_into_soulmate`, `#remove_from_soulmate` and `.search` methods, along with an endpoint for the UI element to hit.  Oh, and I added a capistrano and rake task to reset soulmate, should things on production get out of sync -- no pun intended.

Since I'm running out of room, here are a few **honorable mentions**:

* Bootstrap
* Authlogic
* FactoryGirl
* MailPreview

# **The Future!**

#### [Chef](https://github.com/opscode/chef)

As I mentioned, we're going to run out of memory very soon.  And since having recipes for server setup is a great idea I figured I'd try to get them done before we make the switch and use Chef to spin up a new, larger droplet.  Learning Chef is going okay - I put Ubuntu 14.04 on VirtualBox.  This way, I'll have the ability to bootstrap it, run recipes, and tear it back down when I fuck up.

One problem is going to be keeping the chef-repo on Github and maintaining secrecy for sensitive files.  From what I can gather, the fine folks at Nordstrom of all places have invented a gem called [chef-vault](https://github.com/Nordstrom/chef-vault) which aims to solve that problem.

#### Better Searching

We'll want to break down soulmate's search results by model (Campaign and Performer) and display avatars associated with each performer.

#### Et cetera

You can check out the open issues on our [Github page](http://github.com/stripstarter/stripstarter) and contribute if you'd like!  Thanks for taking the time to read this.