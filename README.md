# local_site_tools
Some scripts I use to create fully functioning domains on my localhost

I frequently find myself needing to spin up a domain on my laptop to test some code I’ve written or debug some customer issues. Usually I need a top-level domain, subdomains, and SSL enabled. I’ve put together a set of tools that allow me to easily standup and teardown domains that run locally. I hope you find them useful.

# Prerequisites
1. Fully patched version of OS X
1. Homebrew

# Setup
1. In the same directory as this readme create a subdirectory named "root_certs"
1. Edit the file rootCA.conf filling in the required fields
1. Run gen_root_ca.sh to create a Root Certificate Authority
1. Import your new CA to keychain (the command to do that is output by gen_root_ca.sh
1. Create a directory named "sites" at the root of your home directory
1. If it doesn't exist, create the directory /etc/resolver (you'll have to do this using sudo)
1. Install Nginx (brew install nginx). Start Nginx using brew services as outlined in the output of the install command
1. Install dnsmasq (brew install dnsmasq)
1. Edit /usr/local/etc/dnsmasq.conf uncommenting the line conf-dir=/usr/local/etc/dnsmasq.d/,*.conf
1. Start dnsmasq using brew services as outlined in the output of the install command

# Using the scripts
If everything is setup correctly, you can add local domains by running
  create_site.sh <domain name>

After running create_site.sh, you should be able to curl http://<domain_name>, https://<domain_name>, and https://*.<domain_name>

To remove the site run:
  remove_site.sh <domain name>
