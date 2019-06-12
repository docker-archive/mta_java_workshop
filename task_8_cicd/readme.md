# Working with CI/CD pipeline hosted in container platform

## Setting up CI/CD pipeline

This task uses `Gitlab-CE` software to configure CI/CD pipeline.

>Because this task uses local volumes to persist data, both Gitlab and Gitlab Runner workloads should be pinned to designated nodes.

1. Review configuration files at `./task_8_cicd/config` folder

    Adjust `Gitlab` configuration or password as needed.

2. Label nodes

    Pick a worker node and label it to run Gitlab instance.

    ```bash
    # get worker node name from command:
    #   docker node ls
    worker_node='worker-1'
    docker node update --label-add versioncontrol=gitlab $worker_node
    ```

    Pick a worker node and label it to run Gitlab runner instance.

    ```bash
    worker_node='worker-2'
    docker node update --label-add cicd=gitlab-runner $worker_node
    ```

    Verify the labels are set on the nodes.

    ```bash
    worker_node='worker-1'
    docker node inspect $worker_node --format '{{json .Spec.Labels}}' | jq -r
    ```

3. Deploy `gitlab` stack

    ```bash
    docker stack deploy -c gitlab-stack.yml cicd
    ```

    Once stack is deployed navigate to `Gitlab` URL (i.e. `http://${UCP_HOST}:9090`).

4. Register runners

    To register runners, you have to run `register` command for each runner instance deployed.
    >if you run stack using `docker-compose` on a local machine, you must use gitlab service name for `GITLAB_HOST` variable. For instance, if deployment name is `cicd`, full gitlab service name should be `cicd_gitlab`.

    * Retrieve Gitlab runner token
        >If you didn't explicitly configure `username` for Gitlab container in `omnibus_config.rb` or via env var, the default username should be `root` and the password as specified in `./config/root_password.txt` file.
        * Login onto Gitlab UI
        * Navigate to Gitlab Runners settings page and copy token
    * Run `register` command
        * Use the runner registration token to register each instance of Gitlab Runner
    >if you don't have/use external URL for your gitlab server that is globally accessible (or resolves within your domain), then you need to configure clone URL that could be your publicly accessible load balancer and port that point to the gitlab instance.

    ```bash
    # get runner registration token from Gitlab console
    $token='<token>'
    GITLAB_HOST='http://cicd_gitlab:80'
    CLONE_URL="http://${UCP_HOST}:9090"
    docker exec -it $(docker ps --format '{{.Names}}\t{{.ID}}'|grep gitlab-runner|cut -f2) gitlab-runner \
    register --non-interactive \
    --url ${GITLAB_HOST} \
    --clone-url ${CLONE_URL} \
    --registration-token $token \
    --executor docker \
    --description "local docker" \
    --docker-image "docker:latest" \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
    ```

## Configure automated builds

1. Setup CI/CD org, team and user

    * Create `ci` org, `build` team and user `gitlab` in DTR.
    * Make `gitlab` user a member of `build` team.
    * Create `java_app_build` repository in DTR and assign `build` team to have `read/write` access to it
    >Alternatively run the script `./create-repo.sh` to create org, team and user for CI/CD pipeline

    ```bash
    # use your DTR FQDN
    export DTR_HOST='dtr.example.com'
    export ADMIN_USER='admin'
    # use UCP admin password
    export ADMIN_PASSWORD='adminPassword'
    ./create-repo.sh
    ```

2. Create project in Gitlab

    * Create project in Gitlab UI
        * on Gitlab landing page select `Create a project`
        * give it a name `java_app` and hit `Create project` button
    * Checkout `java_app` project into `./task_8_cicd` folder

    ```bash
    # use the FQDN for your UCP cluster
    UCP_HOST='ucpapp.example.com'
    git clone http://${UCP_HOST}/root/java_app.git
    ```

    >If asked, provide `username` and `password` configured during `gitlab` setup. By default it's user `root` and password `MySuperSecretAndSecurePass0rd!`

    * Copy application source files into `java_app` folder

    ```bash
    cp -r ../task_3/java_app_v2/* ./java_app/
    ```

3. Configure CI pipeline

    * Create `.gitlab-ci.yml` file that describes your build process.
    >Feel free to use example at `./build/.gitlab-ci.yml` file.

    ```bash
    cp ./build/.gitlab-ci.yml ./java_app/
    ```

    * Create `java_app_build` image repository in DTR for `admin` user.
    * Open `./java_app/.gitlab-ci.yml` file and set `DTR_PASSWORD` and `DTR_SERVER` variables.
    >Use your UCP `admin` user account credentials for DTR user and password variables.

4. Run project build

    Commit code for `java_app` that contains `.gitlab-ci.yml` file and push it to remote git repository.

    ```bash
    git add .
    git commit -m 'app commit'
    git push origin master
    ```

5. Verify the result of build job

    * Navigate to `java_app` project in Gitlab and review the output of CI/CD Pipeline tasks.
    * Navigate to `java_app_build` repository in DTR and view its tags. The image tag should match the job build number in Gitlab.
