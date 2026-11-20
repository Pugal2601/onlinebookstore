
pipeline {
    agent any

    environment {
        PATH = "/opt/maven/bin:${env.PATH}"

        REPO_URL = 'https://github.com/Pugal2601/onlinebookstore.git'
        BRANCH = 'master'

        IMAGE_NAME = 'pugal123/onlinebookstore'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: "${BRANCH}",
                    url: "${REPO_URL}"
            }
        }

        stage('Verify Environment') {
            steps {
                sh '''
                    java -version
                    mvn -version
                    docker --version
                    kubectl version --client
                '''
            }
        }

        stage('Build Java Application') {
            steps {
                sh '''
                    mvn -B clean package
                    test -f target/onlinebookstore.war
                    ls -lh target/onlinebookstore.war
                '''
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                sh '''
                    trivy fs \
                    --scanners vuln,misconfig,secret \
                    --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    .
              '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                      -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        
        stage('Trivy Image Scan') {
            steps {
                sh '''
                    trivy image \
                    --scanners vuln,secret \
                    --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    ${IMAGE_NAME}:${IMAGE_TAG}
              '''
          }
      }


        stage('Push Image to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKERHUB_USER',
                        passwordVariable: 'DOCKERHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        echo "$DOCKERHUB_TOKEN" | docker login \
                          -u "$DOCKERHUB_USER" --password-stdin

                        docker push ${IMAGE_NAME}:${IMAGE_TAG}

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'bookstore-kubeconfig',
                        variable: 'KUBECONFIG'
                    )
                ]) {
                    sh '''
                        echo "Applying Kubernetes Service"

                        kubectl apply -f k8s/service.yaml

                        echo "Updating Deployment image"

                        sed "s|pugal123/onlinebookstore:initial|${IMAGE_NAME}:${IMAGE_TAG}|g" \
                          k8s/deployment.yaml > deployment-build.yaml

                        kubectl apply -f deployment-build.yaml

                        echo "Waiting for Kubernetes rollout"

                        kubectl rollout status deployment/onlinebookstore \
                          -n bookstore --timeout=180s
                    '''
                }
            }
        }

        stage('Verify Kubernetes Deployment') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'bookstore-kubeconfig',
                        variable: 'KUBECONFIG'
                    )
                ]) {
                    sh '''
                        echo "Checking Pods"

                        kubectl get pods -n bookstore -o wide

                        echo "Checking Deployment"

                        kubectl get deployments -n bookstore

                        echo "Checking Service"

                        kubectl get services -n bookstore
                    '''
                }
            }
        }
    }

    post {
        success {
            echo """
            Online Bookstore deployed successfully!

            Image: ${IMAGE_NAME}:${IMAGE_TAG}
            Namespace: bookstore
            Replicas: 2
            NodePort: 30080
            """
        }

        failure {
            echo 'Pipeline failed. Check Jenkins Console Output.'
        }
    }
}
