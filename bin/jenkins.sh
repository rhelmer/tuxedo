#!/bin/bash
set -e

# PHP tests
export FILEPATH="`pwd`/bouncer/php/"
pushd bouncer/php/cfg
cp config-dist.php config.php
sed -i .bak "s%/var/www/download%$FILEPATH%" config.php
popd
pushd bouncer/tests
# FIXME replace w/ phpunit
for f in *.php
do
    OUTPUT=`php -q $f 2>&1`
    echo $OUTPUT
    echo $OUTPUT | grep OK > /dev/null 2>&1
done
popd

# Django tests
virtualenv .venv
. .venv/bin/activate
pip install -r requirements.txt
cp settings-dist.py settings.py
cat << EOF > local_settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'bouncer',
        'USER': 'bouncer',
        'PASSWORD': 'bouncer',
        'HOST': 'localhost',
        'PORT': '',
        'OPTIONS': {
            'init_command': 'SET storage_engine=InnoDB',
            'charset' : 'utf8',
            'use_unicode' : True,
        },
        'TEST_CHARSET': 'utf8',
        'TEST_COLLATION': 'utf8_general_ci',
    },
}
EOF

python manage.py test
