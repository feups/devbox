# WARNING: This file is 'source' by a shell script
# Don't use any space before or after the '=' sign
# Ensure the file keeps its 'unix' file encoding (no Windows CR LF)

# Your full user name e.g "John Doe"
user_name=""
# The email address you want to be registered for your 'git commit'
user_email=""
# Your Active directory id (e.g "jdoe")
user_id=""
# Your Active directory password. It is used by the `cicd` command line (orchestration).
user_pwd=""
# The default stack name you are working with. This will enabled the `mr`  puppet-stack-$stackname repo
# eg. "bos"
user_stack=""
# Do you want to download eclipse plugins such as egit or m2e ?
eclipse_plugins=true
# Do you want to download the eclipse plugin geppetto (puppet supported plugin)
eclipse_geppetto=true
# Enter the url of your fork of the `vcsh_mr_template` if you maintain one.
mr_template_repo_url="git://github.com/CIRB/vcsh_mr_template.git"
