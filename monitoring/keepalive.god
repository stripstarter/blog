God.watch do |w|
  w.name = "blog"
  w.start = "cd /var/www/blog && jekyll start"
  w.keepalive
end