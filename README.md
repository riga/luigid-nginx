# riga/luigid-nginx

Docker image to run a [luigi](http://luigi.readthedocs.io/) scheduler behind an [nginx](http://nginx.org) reverse proxy with basic authentication.


## Exposed ports

- 80: nginx
- 8082: luigi scheduler

When starting the container, forward the nginx port to your host machine to access the luigi scheduler with basic authentication, or directly forward the luigi scheduler port to avoid authentication.


## Important files

- `/etc/nginx/nginx.conf`: The nginx config.
- `/luigi/luigi.conf`: The luigi config.
- `/luigi/htpasswd`: The [htpasswd](http://www.htaccesstools.com/articles/htpasswd/) file containing valid user-password combinations. By default, the user `user` with password `pass` is accepted. You might want to forward a different file to this location for obvious security reasons (see example below).
- `/luigi/state`: The state file created and/or loaded by the luigi scheduler.
- `/luigi/history.db`: The sqlite database containing the task history. The history is recorded when you pass `-e LUIGI_TASK_HISTORY=1` to the `docker run` command.


## Examples

Run as a process on host port 8080:

```bash
# with basic auth
docker run --rm -ti -p 8080:80 riga/luigid-nginx

# without basic auth
docker run --rm -ti -p 8080:8082 riga/luigid-nginx
```

Run interactively:

```bash
docker run --rm -ti -p 8080:80 riga/luigid-nginx bash
> run_nginx
> run_luigid
```

Run as a process, update basic auth credentials:

```bash
htpasswd -n -b custom_user custom_pass > custom_htpasswd
docker run --rm -ti -p 8080:80 -v $PWD/custom_htpasswd:/luigi/htpasswd riga/luigid-nginx
```

Run and record task history:

```bash
touch history.db
docker run --rm -ti -p 8080:80 -v $PWD/history.db:/luigi/history.db -e LUIGI_TASK_HISTORY=1 riga/luigid-nginx
```
