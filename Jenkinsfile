
pipeline {
    agent any

    environment {
        PATH = "/opt/maven/bin:${env.PATH}"

        REPO_URL = 'https://github.com/Pugal2601/onlinebookstore.git'
        BRANCH = 'master'

        APP_NAME = 'onlinebookstore'
        CONTAINER_NAME = 'onlinebookstore'

        HOST_PORT = '8081'
        CONTAINER_PORT = '8080'

        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Cloning Online Bookstore repository'

                git branch: "${BRANCH}",
                    url: "${REPO_URL}"
            }
        }

        stage('Verify Environment') {
            steps {
                sh '''
                    java -version
                    mvn -version
                    git --version
                    docker --version
                    docker info
                '''
            }
        }

        stage('Build Java Application') {
            steps {
                echo 'Building WAR using Maven'

                sh '''
                    mvn -B clean package

                    test -f target/onlinebookstore.war

                    ls -lh target/onlinebookstore.war
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Creating Online Bookstore Docker image'

                sh '''
                    docker build \
                        -t ${APP_NAME}:${IMAGE_TAG} \
                        -t ${APP_NAME}:latest .
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                echo 'Deploying application container'

                sh '''
                    docker rm -f ${CONTAINER_NAME} || true

                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p ${HOST_PORT}:${CONTAINER_PORT} \
                        ${APP_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Verify Container') {
            steps {
                sh '''
                    sleep 15

                    if [ "$(docker inspect -f '{{.State.Running}}' ${CONTAINER_NAME})" != "true" ]; then
                        echo "Container is not running"
                        docker logs ${CONTAINER_NAME}
                        exit 1
                    fi

                    echo "Container is running successfully"

                    docker ps --filter "name=${CONTAINER_NAME}"

                    docker logs --tail 30 ${CONTAINER_NAME}
                '''
            }
        }
    }

    post {
        success {
            echo """
            Online Bookstore deployment successful!

            Docker Image: ${APP_NAME}:${IMAGE_TAG}
            Container: ${CONTAINER_NAME}
            Application Port: ${HOST_PORT}
            """
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }
    }
}
