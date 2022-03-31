#!/bin/sh

echo 'db/' > /data/.backupignore
echo 'core' >> /data/.backupignore

configurator
exec tini electrs
