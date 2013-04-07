
DATABASES = {
    'default': {
        'ENGINE': '{{ database['backend'] }}', # Add 'postgresql_psycopg2', 'postgresql', 'mysql', 'sqlite3' or 'oracle'.
        'NAME': '{{ database['name'] }}',                      # Or path to database file if using sqlite3.
        'USER': '{{ database['user'] }}',                      # Not used with sqlite3.
        'PASSWORD':'{{ database['password'] }}',                   # Not used with sqlite3.
        'HOST': '{{ database['host'] }}',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '{{ database['port'] }}',                      # Set to empty string for default. Not used with sqlite3.
    }
}


ADMINS = (
     ('Admin Name', 'example@gmail.com'),
)

MANAGERS = (
     ('Manager Name', 'example@gmail.com'),
)

DEBUG = {{ debug }}
TEMPLATE_DEBUG = {{ template_debug }}

SECRET_KEY = '{{ secret_key }}'