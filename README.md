# pg_d_binding is a D language binding project for PostgreSQL

It's alpha version now.

PostgreSQL 18 only supported at this moment.

### Build
- Build using `./build.sh` (needs ldc2 compiler)
- Get PostgreSQL `$libdir` directory name, for example:
```
export libdir=$(sudo -i -u postgres psql -Aqtc "SELECT setting FROM pg_config where name = 'LIBDIR'")
echo $libdir
```
- Copy library .so file there: `sudo cp extension_example.so $libdir`
- Run `extension_example.sql` like:
```
cat extension_example.sql | sudo -i -u postgres psql -f -
```