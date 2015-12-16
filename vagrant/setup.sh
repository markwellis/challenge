sudo apt-get update
sudo apt-get install -y postgresql-server-dev-9.4 build-essential perlbrew libexpat1-dev

perlbrew init
echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bash_profile
. ~/.bash_profile

#why perlbrew? because the system perl is usually messed with, and this is cleaner and newer
perlbrew install perl-5.22.1 -n
perlbrew switch perl-5.22.1
perlbrew install-cpanm
cpanm Carton -n

cd /vagrant
carton install
