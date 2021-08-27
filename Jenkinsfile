pipeline {
    agent any
    
    parameters {
        string(name: 'PROJECT', defaultValue: 'https://github.com/rajapiconnect1/spring-boot-configmaps-demo.git', description: 'Enter Project anme ')
               
        string(name: 'SERVICE_NAME', defaultValue: 'springboot-configmaps-demo', description: 'Enter Project anme ')

        }
    stages {
        stage('Checkout') {
            steps {

                 echo "Hello ${params.PROJECT} "
               checkout([$class: 'GitSCM', branches: [[name: '*/master']], userRemoteConfigs: [[url: 'https://github.com/rajapiconnect1/spring-boot-configmaps-demo.git']]])
	
            }
        }    
        stage('Build') { 
            steps {
                echo 'Hello World!!!'
                sh 'mvn clean package' 
            }
        }

        stage('Dockerize') { 
            steps {
                echo 'Dockerizing application'
                
                sh 'docker logout'
                sh 'docker login -u rajapiconnect1 -p "Rajesh@3200" docker.io'
                sh "docker build -t rajapiconnect1/${params.SERVICE_NAME} ."
                sh "docker tag rajapiconnect1/${params.SERVICE_NAME} rajapiconnect1/${params.SERVICE_NAME}"
                sh "docker push rajapiconnect1/${params.SERVICE_NAME}"
            }
        }

         stage('Deploy') { 

            steps {
                echo 'Deploying application into OCP ....'
                sh "oc login --token=${params.OCTOKEN} --server=https://api.sandbox.x8i5.p1.openshiftapps.com:6443"
                
                
                
                sh "oc create -f ${env.WORKSPACE}/deployment.yaml"

                timeout(time: 1, unit: 'MINUTES') {
                    
                }

                sh "oc create -f ${env.WORKSPACE}/service.yaml"

                timeout(time: 1, unit: 'MINUTES') {
                    
                }

                sh "oc expose service/${params.SERVICE_NAME}"

                timeout(time: 1, unit: 'MINUTES') {
                    
                }

                try {
                    // Fails with non-zero exit if dir1 does not exist
                    def dir1 = sh(script:'ls -la .', returnStdout:true).trim()
                } catch (Exception ex) {
                    println("Unable to read dir1: ${ex}")
                }
            }
        }

    }
}

