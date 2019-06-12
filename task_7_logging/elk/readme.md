# ELK logging solution

The solution uses [Journalbeat](https://www.elastic.co/guide/en/beats/journalbeat/current/index.html) to scrape container logs and send them to ElasticSearch either directly or route via [Logstash](https://www.elastic.co/products/logstash).
Feel free to choose either option or even try both.

1. Configure `log-driver` setting in `/etc/docker/daemon.json` on each Docker host

    ```json
    {
        "log-driver": "journald",
        "log-opts": {
            "tag": "{{.ImageName}}"
        }
    }
    ```

    you can use `./set-logdriver.sh` to apply the change to multiple Linux machines.
    >The script uses `PDSH` utility to apply the change to multiple machines

    ```bash
    cd ./task_7_logging
    # example host list
    hostlist='ucp1,dtr1,wrkr1,wrkr2'
    ./set-logdriver.sh $hostlist 'ubuntu' "$HOME/.ssh/id_rsa"
    ```

    >`hostlist` variable should have a comma separated list of machine names or IP addresses.  
    >**Second** parameter must specify Linux machine user.  
    >**Third** parameter must point to SSH private key that allows SSH access to the machines.

2. Restart the Docker daemon on each Docker host for changes to take effect

    ```bash
    sudo systemctl restart docker.service
    ```

    you can use `PDSH` to restart `docker.service` on multiple machines

    ```bash
    pdsh -w $hostlist "sudo systemctl restart docker.service"
    ```

3. Review contents for ELK stack under paths `./elasticsearch`, `./logstash`, `./kibana` as well as `Journalbeat` under path `./journalbeat`

4. Deploy `elk` stack

    >the solution uses OSS products from Elastic.co  
    >Elasticsearch: `docker.elastic.co/elasticsearch/elasticsearch-oss:7.1.1`  
    >Logstash: `docker.elastic.co/logstash/logstash-oss:7.1.1`  
    >Kibana: `docker.elastic.co/kibana/kibana-oss:7.1.1`

    ```bash
    cd ./elk
    docker stack deploy -c elk-stack.yml elk
    ```

    >`kibana` container may take a moment longer to deploy than `elasticsearch` or `logstash`

5. Deploy `Journalbeat` to scrape container logs and ship to `ElasticSearch`

    Once `elk` stack is up and running proceed to setting up `Journalbeat` component. This task offers two ways to ship container logs to `ElasticSearch`:

    1. `Journalbeat` ships logs directly to `ElasticSearch`. This option is great if the format of the logs suites your needs and you don't need more sophisticated features of `Logstash` pipelines to filter and mutate the logs.
    2. `Journalbeat` ships logs to `Logstash` first and then `Logstash` sends them to `ElasticSearch`. This option is good if you want to mutate the logs or apply more sophisticated filtering that `Logstash` pipelines offer.

    >`Logstash` features are beyond the scope of this task. Refer to [Logstash](https://www.elastic.co/products/logstash) docs to learn more about its capabilities.

    - ***[Option 1]* Ship logs to ElasticSearch directly from Journalbeat**

        >if `Option 2` was used first, make sure to remove the `monitoring` stack and then follow steps for this approach.  
        >`$ docker stack rm monitoring`

        Explore `Journalbeat` configuration defined in `./elk/journalbeat/config/journalbeat.elasticsearch.yml` file.

        >use `./elk/journalbeat/config/journalbeat_7-1-1.reference.yml` to learn more about configuration options.

        Open `journalbeat-stack.yml` and set `journalbeat_config` to look like this:

        ```yaml
        configs:
        journalbeat_config:
            file: ./journalbeat/config/journalbeat.elasticsearch.yml
        ```

        Save the changes and deploy the stack:

        ```bash
        docker stack deploy -c journalbeat-stack.yml monitoring
        ```

        Open `Kibana` console `https://${UCP_HOST}:5601` and wait for index pattern `jb_es-<version>-<date>` to appear. Then configure the index pattern and veiw logs in the dashboard.

    - ***[Option 2]* Ship logs to Logstash from Journalbeat**

        >if `Option 1` was used first, make sure to remove the `monitoring` stack and then follow steps for this approach.  
        >`$ docker stack rm monitoring`

        Explore `Journalbeat` configuration defined in `./elk/journalbeat/config/journalbeat.logstash.yml` file.

        >use `./elk/journalbeat/config/journalbeat_7-1-1.reference.yml` to learn more about configuration options.

        Open `journalbeat-stack.yml` and set `journalbeat_config` to look like this:

        ```yaml
        configs:
        journalbeat_config:
            file: ./journalbeat/config/journalbeat.logstash.yml
        ```

        Save the changes and deploy the stack:

        ```bash
        docker stack deploy -c journalbeat-stack.yml monitoring
        ```

        Open `Kibana` console `https://${UCP_HOST}:5601` and wait for index pattern `jb_ls-<version>-<date>` to appear. Then configure the index pattern and veiw logs in the dashboard.

Note that container logs are written into host's `journald` logs by `journald` log driver configured in `daemon.json` and scraped by `Journalbeat` component. This approach aligns with Docker's recommendation to use either standard log drivers or `Docker API` to scrape container logs. It is a better way to collect container logs than scraping physical log files that can be found at `/var/lib/docker/containers/*/*-json.log` on each Docker host.
