---
layout: post
title:  "Some days, all you can do is laugh"
date:   2014-09-07 23:03:00
categories: stripstarter troubleshooting
---

I was trying to `knife bootstrap` a virtual machine I had running in my computer.  Since it has a dynamic IP, I go into the machine itself to grab it from ifconfig and use that.  Well, I kept getting:

{% highlight bash %}
mzemel-mbp:chef-repo mzemel$ knife bootstrap 192.168.56.101 --sudo -x michael -p **** -N node4
Connecting to 192.168.56.101
ERROR: Errno::EADDRNOTAVAIL: Can't assign requested address - connect(2) for "192.168.56.101" port 0
{% endhighlight %}

So I thought... hm, maybe it's cause my address is in 192.168.x.x instead of 10/8 like it was before... but those are equivalent, no?  Well, maybe if I put it in host-only, it'll get back to 10/8.  Nope...

Turns out `-p` was lowercased.  That means the port.  I was trying to connect on a bad port.  Fuck.