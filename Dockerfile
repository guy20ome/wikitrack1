
# Copy LocalSettings.php into the MediaWiki root
COPY config/LocalSettings.php /var/www/html/LocalSettings.php

# restart Apache services
#CMD apache2-foreground


