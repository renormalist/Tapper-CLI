#! /bin/bash

if [ -e ~/.tapper ] ; then
    echo "You already have a ~/.tapper/ -- exiting." 
    echo "Maybe do your own"
    echo "  tapper init --default"
    exit 1
fi

echo ""
echo "**************************************************"
echo ""
echo "Please install dependencies first, like this:"
echo ""
echo "sudo apt-get install gcc"
echo "sudo apt-get install make"
echo "sudo apt-get install libsqlite3-dev"
echo "sudo apt-get install libexpat1-dev"
echo "sudo apt-get install libxml2-dev"
echo "sudo apt-get install libz-dev"
echo "sudo apt-get install libgmp-dev"
echo ""
echo "**************************************************"
echo ""
sleep 2

curl -kL http://install.perlbrew.pl | bash
source ~/perl5/perlbrew/etc/bashrc
perlbrew install perl-stable

echo ""
echo "**************************************************"
echo ""
echo "Don't forget to add this line to your ~/.bashrc:"
echo ""
echo "  source ~/perl5/perlbrew/etc/bashrc"
echo ""
echo "**************************************************"
echo ""
sleep 5

curl -L http://cpanmin.us | perl - App::cpanminus
cpanm --force Template::Plugin::Autoformat
cpanm Catalyst::Action::RenderView
cpanm Task::Tapper::Hello::World
cpanm Task::Tapper::Hello::World::Automation

( echo "y" ; echo "y" ) | tapper init --default
