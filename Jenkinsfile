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
      
      echo "$BUILD_ID"
      echo "$BUILD_URL"
      echo "$JOB_NAME"
      echo env.GIT_REPO
      echo env.GITHUB_PR
      echo env.GITHUB_COMMIT
      println "Primary owner ID: ${ownership.job.primaryOwnerId}"
      println "Primary owner e-mail: ${ownership.job.primaryOwnerEmail}"
      println "Secondary owner IDs: ${ownership.job.secondaryOwnerIds}"
      println "Secondary owner e-mails: ${ownership.job.secondaryOwnerEmails}"
      def SEC_OWNERS_LIST=${ownership.job.secondaryOwnerEmails}
      def SEC_OWNERS=SEC_OWNERS_LIST.join(", ")
      
      echo "${ownership.job.primaryOwnerEmail},$SEC_OWNERS"
      wrap([$class: 'BuildUser']) {
      echo "${BUILD_USER_EMAIL}" 
       }
       
    
          
    }
  }
    
   
} 
}
