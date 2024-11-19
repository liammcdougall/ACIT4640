
## Using a remote backend
## GitOps

GitOps is a little like DevOps in that isn't a tool or framework that you can add to your projects.

"GitOps uses a Git repository as the single source of truth for infrastructure definitions." - GitLab docs

Code that defines your infrastructure is pushed to a Git repository. From there merge or pull requests are used to trigger a CI/CD pipeline that will provision your infrastructure. Your CI/CD pipeline could be a service like Spacelift, or GitHub actions... The tools you use often depends on your needs and personal preferences of your development team. 

Automating some of these components allow teams to deploy updates faster and experiment with new features. In theory when you have a working pipeline it is relatively easy to create a new branch that would allow you to try out a new feature in an isolated environment.

