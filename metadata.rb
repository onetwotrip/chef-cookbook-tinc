name 'tinc'
maintainer 'Maciej Pasternacki'
maintainer_email 'maciej@3ofcoins.net'
license 'MIT'
description 'Installs and configures Tinc VPN'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.0'

supports 'ubuntu', '>= 12.04'

depends 'sysctl'
