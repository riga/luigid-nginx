FROM centos:7

# labels
LABEL name="luigid-nginx"
LABEL version="0.0.1"

# ports
EXPOSE 80
EXPOSE 8082

# workdir
WORKDIR /luigi

# yum setup
RUN yum -y update; yum clean all
RUN yum -y install yum-plugin-priorities yum-utils; yum clean all
RUN yum install -y epel-release; yum clean all
RUN yum -y groupinstall development; yum clean all
RUN yum -y install libffi-devel openssl-devel bzip2-devel json-c-devel curl-devel gcc-c++ which \
    wget nano htop screen git cmake cmake3 boost-devel boost-python python-pip nginx httpd-tools; \
    yum clean all

# nginx setup
COPY nginx.conf /etc/nginx/nginx.conf
RUN systemctl enable nginx
# add a default htpasswd file for user "user" with password "pass"
# as this is obviously not secure, make sure to forward a custom htpasswd file into the container
RUN htpasswd -n -b user pass > /luigi/htpasswd

# luigi setup
COPY luigi.conf luigi.conf
ENV LUIGI_CONFIG_PATH /luigi/luigi.conf
RUN echo -e '\n\
export PATH="$PATH:$HOME/.local/bin"\n\
export PYTHONPATH="$PYTHONPATH:$HOME/.local/lib/python2.7/site-packages"\n' >> /etc/bashrc
RUN pip install luigi --user

# default command, saved as an alias
RUN echo 'alias run_nginx="nginx"' >> /etc/bashrc
RUN echo 'alias run_luigid="luigid --address 0.0.0.0 --port 8082 --state-path /luigi/state"' >> /etc/bashrc
CMD bash -i -l -c "run_nginx; run_luigid"
