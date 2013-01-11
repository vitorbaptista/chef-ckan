Chef-CKAN
=========

This project builds a Virtual Machine with the latest CKAN ready to go. This is
only intended for development.

Quickstart
----------

Install [Vagrant](http://www.vagrantup.com/), clone this repository, then:

    $ vagrant up

This will download the VM image, install and configure CKAN and all its
dependencies, and run its tests. Go grab a coffee and let it run.

After it's finished, do:

    $ vagrant ssh
    $ source ~/pyenv/bin/activate
    $ cd ~/pyenv/src/ckan
    $ paster serve development.ini

You can check http://localhost:5000 to see if everything went well. You should
see your newly created CKAN installation. Now you can start playing :)

I would start creating an admin user. Follow CKAN's [Post-Installation
Setup](http://docs.ckan.org/en/ckan-1.8/post-installation.html). 

Enjoy!
