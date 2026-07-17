# pg_d_binding is a D language binding project for PostgreSQL

It's alpha (concept) version now.

CAUTION! At least at this moment it's a lot of LLM generated content in the project! I hope it will be changed in time.

PostgreSQL 18 only supported at this moment.

### Build
- Build using `./build.sh` (needs ldc2 compiler and installed PostgreSQL 18 from PGDG repo on CentOS-based Linux; for other distros patch the directories yourself)
- Run `test.sql` like:
```
cat test.sql | sudo -i -u postgres psql -a -f -
```

