
pipeline {
    agent any

    environment {
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

        stage('Verify Tools') {
            steps {
                sh '''
                    echo "Checking Java version"
                    java -version

                    echo "Checking Maven version"
                    mvn -version

                    echo "Checking Docker version"
                    docker --version

                    echo "Checking Docker daemon"
                    docker info
                '''
            }
        }

        stage('Build Application') {
            steps {
                echo 'Building Java WAR application'

                sh '''
                    mvn -B clean package

                    echo "Checking generated WAR file"

                    test -f target/onlinebookstore.war

                    ls -lh target/onlinebookstore.war
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image'

                sh '''
                    docker build \
                        -t ${APP_NAME}:${IMAGE_TAG} \
                        -t ${APP_NAME}:latest .
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                echo 'Deploying Online Bookstore container'

                sh '''
                    # Remove previous container if present
                    docker rm -f ${CONTAINER_NAME} || true

                    # Start new container
                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        --restart unless-stopped \
                        -p ${HOST_PORT}:${CONTAINER_PORT} \
                        ${APP_NAME}:${IMAGE_TAG}

                    echo "Container deployment completed"
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    echo "Checking container status"

                    docker ps --filter "name=${CONTAINER_NAME}"

                    echo "Checking application logs"

                    sleep 10

                    docker logs --tail 30 ${CONTAINER_NAME}
                '''
            }
        }
    }

    post {
        success {
            echo """
            BUILD SUCCESSFUL!

            Application: Online Bookstore
            Container: onlinebookstore
            Image: ${APP_NAME}:${IMAGE_TAG}

            Access URL:
            http://YOUR_JENKINS_HOST_IP:${HOST_PORT}/onlinebookstore/
            """
        }

        failure {
            echo 'BUILD FAILED! Check Jenkins Console Output.'
        }
    }
}
