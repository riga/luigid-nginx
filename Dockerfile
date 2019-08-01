FROM centos:7

# labels
LABEL name="riga/luigid-nginx"
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
COPY luigi_taskhistory.conf luigi_taskhistory.conf
ENV LUIGI_TASK_HISTORY 0
RUN echo -e '\n\
export PATH="$PATH:$HOME/.local/bin"\n\
export PYTHONPATH="$PYTHONPATH:$HOME/.local/lib/python2.7/site-packages"\n' >> /etc/bashrc
RUN pip install luigi --user

# default command, split into functions
RUN echo $'\n\
run_nginx() {\n\
    nginx\n\
}\n\
export -f run_nginx\n' >> /etc/bashrc

RUN echo $'\n\
run_luigid() {\n\
    local luigi_config_path="/luigi/luigi.conf"\n\
    [ "$LUIGI_TASK_HISTORY" = "1" ] && luigi_config_path="/luigi/luigi_taskhistory.conf"\n\
    LUIGI_CONFIG_PATH="$luigi_config_path" luigid --address 0.0.0.0 --port 8082 --state-path /luigi/state\n\
}\n\
export -f run_luigid\n' >> /etc/bashrc

CMD bash -i -l -c "run_nginx; run_luigid"
