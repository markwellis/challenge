#i should check if update has ran already today, but that's more work and update is quick enough
sudo apt-get update

sudo apt-get install -y postgresql-9.4 postgresql-server-dev-9.4 build-essential perlbrew libexpat1-dev

#why perlbrew? because the system perl is usually messed with, and this is cleaner and newer
#setup perl
if [ ! -f ~/perl5/perlbrew/etc/bashrc ]; then
    perlbrew init
    echo 'source ~/perl5/perlbrew/etc/bashrc' >> ~/.bash_profile
    . ~/.bash_profile
fi

if [[ ! $(perlbrew list | fgrep 'perl-5.22.1') ]]; then 
    perlbrew install perl-5.22.1 -n
    perlbrew switch perl-5.22.1
    perlbrew install-cpanm
    cpanm Carton -n
fi

#install the required dependencies
cd /vagrant
carton install

#setup the db
if [[ ! $(sudo -u postgres psql -t -c "SELECT datname FROM pg_database WHERE datname = 'challenge'") ]]; then 
    sudo -u postgres psql -c "CREATE USER challenger WITH PASSWORD 'reallysecure';"
    sudo -u postgres createdb challenge -O challenger

    #do this as the challenger user so that the ownership is correct, and to test the user is setup correct
    PGPASSWORD='reallysecure' psql -U challenger -h localhost challenge < /vagrant/sql/create.sql
fi
