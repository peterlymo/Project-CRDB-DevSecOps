pipeline {
    agent any
    environment {
        serviceName = "devsecops-svc"
        applicationURL="http://master"
        applicationURI="increment/99"
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "maven_new"
    }

    stages {
        stage('Build') {
            steps {
                sh "mvn clean package -DskipTests=true"
                archive 'target/*.jar'
            }
        }
           stage('Test') {
            steps {
                sh "ls ; mvn test"
            }
            post{
                always {
                    junit 'target/surefire-reports/*.xml'
                    jacoco (execPattern: 'target/jacoco.exec')
                  }
             }
        }
           stage('Mutation Tests - PIT') {
              steps {
                  sh "mvn org.pitest:pitest-maven:mutationCoverage"
               }
            post {
              always{
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
        }

        //    stage('SonarQube Test- SAST') {
        //     steps {
        //             sh " mvn clean verify sonar:sonar \
        //               -Dsonar.projectKey=devsecops-check \
        //               -Dsonar.projectName='devsecops-check' \
        //               -Dsonar.host.url=http://node1:9000 \
        //               -Dsonar.token=sqp_f4267c4125e62a52487d047dd5f5280f72256876"           
        //     }
        // }


            stage('SonarQube - SAST') {
      steps {
       withSonarQubeEnv('SonarQube') {
          sh "mvn sonar:sonar \
                               -Dsonar.projectKey=devsecops-check \
                               -Dsonar.host.url=http://node1:9000"
        }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
         }
       }
    }




          stage('Vulnerability Scan - Docker') {
            steps {
                parallel(
                    "Dependency Scan": {
                        sh "mvn dependency-check:check"
                    },
                    "Trivy Scan":{
                        sh "bash trivy-docker-image-scan.sh"
                    }
                 )
              }
                post {
                   always {
                      dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                }
             }
          }

        
           stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "github_account", url: "https://ghcr.io/"]) {
                sh 'printenv'
                sh 'sudo docker build -t ghcr.io/peterlymo/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push ghcr.io/peterlymo/numeric-app:""$GIT_COMMIT""'
            }
         }
      }
           stage('K8S Deployment - DEV') {
               steps {  
                 withKubeConfig([credentialsId: 'kubeconfig']) {
                 sh "sed -i 's#replace#ghcr.io/peterlymo/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                 sh "kubectl apply -f k8s_deployment_service.yaml"
             }
          }
      }   

               stage('Integration Tests - DEV') {
            steps {
              script {
                 try {
                   withKubeConfig([credentialsId: 'kubeconfig']) {
                   sh "bash integration-test.sh"
                  }
             } catch (e) {
             withKubeConfig([credentialsId: 'kubeconfig']) {
               sh "kubectl -n default rollout undo deploy ${deploymentName}"
             }
             throw e
             }
          }
       }
     }

        stage('OWASP ZAP - DAST') {
           steps {
             withKubeConfig([credentialsId: 'kubeconfig']) {
             sh 'bash zap.sh baseline $applicationURL'
           }
        }
        post {
            always {
               publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report']) 
            }
        }
     }   
   }
}
