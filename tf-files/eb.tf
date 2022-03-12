/* resource "aws_s3_bucket" "eb_bucket" {
    bucket = "eb-python-bucket"
} */

/* resource "aws_s3_bucket_object" "eb_bucket_obj" {
    bucket = aws_s3_bucket.eb_bucket.id
    key = "beanstalk/app.zip"
    source = "app.zip"  
} */

/* resource "aws_elastic_beanstalk_application" "eb_app" {
  name  = "eb-tf-app"
  description = "simple flask app"

}
 */
/* resource "aws_elastic_beanstalk_application_version" "eb_app_ver" {
    bucket = aws_s3_bucket.eb_bucket.id
    key = aws_s3_bucket_object.eb_bucket_obj.id
    application = aws_elastic_beanstalk_application.eb_app.name
    name = "eb-tf-app-version-label"

} */

/* resource "aws_elastic_beanstalk_environment" "tfenv" {

  name = "eb-tf-env"
  application = aws_elastic_beanstalk_application.eb_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.11 running Python 3.8"
  description = "environment for flask app"
  #version_label = aws_elastic_beanstalk_application_version.eb_app_ver.name

  setting {
      namespace = "aws:autoscaling:launchconfiguration"
      name = "IamInstanceProfile"
      value = "aws-elasticbeanstalk-ec2-role"
  }

} */