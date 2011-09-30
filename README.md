## Require

* Ruby 1.9.2
* bundler


## Install

```
$ git clone git://github.com/r7kamura/yuno.git
$ cd yuno
$ bundle install
$ shotgun # or `bundle exec shotgun` or `rackup`
$ open http://localhost:9393
```


## Create a new blog
Here is an example for using [Heroku](http://www.heroku.com/).

```
# create a new blog on Heroku
# (your blog's URL will be http://[NAME].heroku.com)
$ heroku create [NAME]


# At first time you use heroku,
# you'll be asked to enter your Heroku credentials.
Enter your Heroku credentials.
Email: joe@example.com
Password:
Uploading ssh public key /Users/joe/.ssh/id_rsa.pub
Created http://[NAME].heroku.com/ | git@heroku.com:[NAME].git
Git remote heroku added
```


## Update your blog

```
# write a entry...
$ vi pages/2011-10-01-hoge.md


# browse
$ shotgun # (if you have not launch server)
$ open http://localhost:9393


# publish
$ git add .
$ git commit -m "add an entry"
$ git push heroku master
```
