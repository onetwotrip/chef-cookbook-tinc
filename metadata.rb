name 'tinc'
maintainer 'OTT Development Team'
maintainer_email 'operations@onetwotrip.com'
license 'MIT'
description 'Installs and configures Tinc VPN'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.3'

supports 'ubuntu', '>= 12.04'

depends 'runit', '~> 1.5.10'
depends 'sysctl'
