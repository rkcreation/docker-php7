#!/usr/bin/env bash
cp ${PHP_CONF_TEMPLATE} ${PHP_CONF_FILE};

sed -i "s|;max_execution_time.*|max_execution_time = ${PHP_CONF_MAX_EXECUTION_TIME}|" ${PHP_CONF_FILE};

sed -i "s|;upload_max_filesize.*|upload_max_filesize = ${PHP_CONF_UPLOAD_LIMIT}|" ${PHP_CONF_FILE};
sed -i "s|;post_max_size.*|post_max_size = ${PHP_CONF_UPLOAD_LIMIT}|" ${PHP_CONF_FILE};

sed -i "s|;date.timezone.*|date.timezone = ${PHP_CONF_TIMEZONE}|" ${PHP_CONF_FILE};
sed -i "s|;phar.readonly.*|phar.readonly = ${PHP_CONF_PHAR_READONLY}|" ${PHP_CONF_FILE};
sed -i "s|;memory_limit.*|memory_limit = ${PHP_CONF_MEMORY_LIMIT}|" ${PHP_CONF_FILE};
sed -i "s|;display_errors.*|display_errors = ${PHP_CONF_DISPLAY_ERRORS}|" ${PHP_CONF_FILE};
sed -i "s|;error_reporting.*|error_reporting = ${PHP_CONF_ERROR_REPORTING}|" ${PHP_CONF_FILE};

sed -i "s|;opcache.memory_consumption.*|opcache.memory_consumption = ${PHP_CONF_OPCACHE_MEMORY_CONSUMPTION}|" ${PHP_CONF_FILE};
sed -i "s|;opcache.interned_strings_buffer.*|opcache.interned_strings_buffer = ${PHP_CONF_OPCACHE_INTERNED_STRINGS_BUFFER}|" ${PHP_CONF_FILE};
sed -i "s|;opcache.max_accelerated_files.*|opcache.max_accelerated_files = ${PHP_CONF_OPCACHE_MAX_ACCELERATED_FILES}|" ${PHP_CONF_FILE};
sed -i "s|;opcache.max_wasted_percentage.*|opcache.max_wasted_percentage = ${PHP_CONF_OPCACHE_MAX_WASTED_PERCENTAGE}|" ${PHP_CONF_FILE};
sed -i "s|;opcache.validate_timestamps.*|opcache.validate_timestamps = ${PHP_CONF_OPCACHE_VALIDATE_TIMESTAMPS}|" ${PHP_CONF_FILE};
sed -i "s|;opcache.revalidate_freq.*|opcache.revalidate_freq = ${PHP_CONF_OPCACHE_REVALIDATE_FREQ}|" ${PHP_CONF_FILE};
sed -i "s|;opcache.fast_shutdown.*|opcache.fast_shutdown = ${PHP_CONF_OPCACHE_FAST_SHUTDOWN}|" ${PHP_CONF_FILE};
sed -i "s|;opcache.enable_cli.*|opcache.enable_cli = ${PHP_CONF_OPCACHE_ENABLE_CLI}|" ${PHP_CONF_FILE};
sed -i "s|;opcache.enable.*|opcache.enable = ${PHP_CONF_OPCACHE_ENABLE}|" ${PHP_CONF_FILE};

