pipeline {
  agent {
    label 'master'
  }
  
  environment {
    GOPATH = "$WORKSPACE"
    GITHUB_COMMIT="$GIT_COMMIT"
    GITHUB_PR="$CHANGE_ID"
  }
  

  stages {
    stage("First") {
      steps {
       script{
        def url="$GIT_URL"
        final git_repo = url.substring(url.lastIndexOf('/') + 1, url.length())
        env.GIT_REPO =git_repo
       
        }
        
      }
       
    }
    stage("printing other variables"){
      steps{
       echo env.BUILD_ID
       echo env.BUILD_URL
       wrap([$class: 'BuildUser']) {
       echo env.BUILD_USER_EMAIL
       }
       echo env.JOB_NAME
       echo env.${ownership.job.primaryOwnerEmail} 
       
      
    }
  }
    
    stage("Build CVE job"){
      steps{
    
      build job: 'dummy-freestyle', parameters: [[$class: 'StringParameterValue', name: 'COMMIT_ID', value:env.GITHUB_COMMIT], [$class: 'StringParameterValue', name: 'GITHUB_REPO', value:"env.GITHUB_REPO"],[$class: 'StringParameterValue', name: 'GITHUB_PR', value:"env.GITHUB_PR"],[$class: 'StringParameterValue', name: 'BUILD_ID', value:"env.BUILD_ID"],[$class: 'StringParameterValue', name: 'BUILD_URL', value:"env.BUILD_URL"],[$class: 'StringParameterValue', name: 'BUILD_USER', value:"env.BUILD_USER"],[$class: 'StringParameterValue', name: 'BUILD_USER_ID', value:"env.BUILD_USER_ID"],[$class: 'StringParameterValue', name: 'BUILD_USER_EMAIL', value:"env.BUILD_USER_EMAIL"],[$class: 'StringParameterValue', name: 'JOB_NAME', value:"env.JOB_NAME"],[$class: 'StringParameterValue', name: 'PRIMARY_JOB_OWNER_ID', value:"env.PRIMARY_JOB_OWNER_ID"],[$class: 'StringParameterValue', name: 'PRIMARY_JOB_OWNER_EMAIL', value:"env.PRIMARY_JOB_OWNER_EMAIL"],[$class: 'StringParameterValue', name: 'SECONDARY_JOB_OWNER_EMAIL', value:"env.SECONDARY_JOB_OWNER_EMAIL"],[$class: 'StringParameterValue', name: 'SECONDARY_JOB_OWNER_ID', value:"env.SECONDARY_JOB_OWNER_ID"]]
      }
  }
} 
}
