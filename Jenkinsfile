pipeline {
    agent any

    environment {
        REPO_URL       = 'https://github.com/Pugal2601/onlinebookstore.git'
        BRANCH_NAME    = 'master'
        APP_NAME       = 'onlinebookstore'
        CONTAINER_NAME = 'onlinebookstore'
        HOST_PORT      = '8081'
        CONTAINER_PORT = '8080'
        PATH           = "/opt/maven/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${BRANCH_NAME}", url: "${REPO_URL}"
            }
        }

        stage('Build with Maven') {
            steps {
                sh '''
                    java -version
                    mvn -B clean package
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                    ARTIFACT=$(find target -maxdepth 1 \\( -name "*.jar" -o -name "*.war" \\) ! -name "*-plain.*" | head -n 1)
                    if [ -z "$ARTIFACT" ]; then
                        echo "ERROR: No build artifact (.jar or .war) found in target/"
                        exit 1
                    fi

                    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
                        echo "Building Docker image using artifact: $ARTIFACT"
                        docker build --build-arg ARTIFACT_FILE="$ARTIFACT" -t ${APP_NAME}:${BUILD_NUMBER} -t ${APP_NAME}:latest .
                        docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
                        docker run -d --name ${CONTAINER_NAME} --restart unless-stopped \
                            -p ${HOST_PORT}:${CONTAINER_PORT} \
                            ${APP_NAME}:latest
                    else
                        echo "Docker daemon unavailable; running JAR directly from target/"
                        pkill -f "$ARTIFACT" 2>/dev/null || true
                        nohup java -jar "$ARTIFACT" > ${APP_NAME}.log 2>&1 &
                    fi
                '''
            }
        }
    }

    post {
        success {
            echo "Build #${BUILD_NUMBER} succeeded. If deployed via Docker, check port ${HOST_PORT}."
        }
        failure {
            echo "Build #${BUILD_NUMBER} failed. Inspect the console log above for details."
        }
    }
}
