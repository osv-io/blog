require "rubygems"
require "bundler/setup"
require "stringex"

generate_dir   = "_site"    # generate site directory
deploy_dir     = "_deploy"  # deploy directory (for Github pages deployment)
deploy_branch  = "gh-pages"

if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  puts '## Set the codepage to 65001 for Windows machines'
  `chcp 65001`
end

desc "Clean jekyll site"
task :clean do
  puts "## Cleaning Site with Jekyll"
  system "jekyll clean"
end

desc "Generate jekyll site"
task :generate do
  puts "## Generating Site with Jekyll"
  system "JEKYLL_ENV=production jekyll build"
end

desc "Preview jekyll site"
task :preview do
  puts "## Preview Site with Jekyll"
  system "jekyll serve --host 0.0.0.0 -w --config _config.yml,preview_config.yml"
end

##############
# Deploying  #
##############

desc "Publish to deploy directory task"
task :publish do
  copy_directory(generate_dir,deploy_dir)
end

desc "Publish private to deploy directory task"
task :publish_private do
  copy_directory(generate_dir,deploy_dir)
  cd "#{deploy_dir}" do 
    system "mv blog/* . && rmdir blog"
    system "rm CNAME"
    system 'find . -type f | xargs sed -i "s/\/javascripts\//\/blog\/javascripts\//g"'
    system 'find . -type f | xargs sed -i "s/\/stylesheets\//\/blog\/stylesheets\//g"'
  end
end

desc "Default deploy task"
task :deploy do
  push("publish",deploy_dir,deploy_branch)
end

desc "Deploy private task"
task :deploy_private do
  push("publish_private",deploy_dir,deploy_branch)
end

desc "Set up _deploy folder and deploy branch for Github Pages deployment"
task :setup_github_pages, :repo do |t, args|
  if args.repo
    repo_url = args.repo
  else
    puts "Enter the read/write url for your repository"
    puts "(For example, 'git@github.com:your_username/your_username.github.io.git)"
    puts "           or 'https://github.com/your_username/your_username.github.io')"
    repo_url = get_stdin("Repository url: ")
  end
  protocol = (repo_url.match(/(^git)@/).nil?) ? 'https' : 'git'
  if protocol == 'git'
    user = repo_url.match(/:([^\/]+)/)[1]
  else
    user = repo_url.match(/github\.com\/([^\/]+)/)[1]
  end
  branch = (repo_url.match(/\/[\w-]+\.github\.(?:io|com)/).nil?) ? 'gh-pages' : 'master'
  project = (branch == 'gh-pages') ? repo_url.match(/\/([^\.]+)/)[1] : ''

  jekyll_config = IO.read('_config.yml')
  jekyll_config.sub!(/^url:.*$/, "url: #{blog_url(user, project)}")
  File.open('_config.yml', 'w') do |f|
    f.write jekyll_config
  end

  rm_rf deploy_dir
  mkdir deploy_dir
  cd "#{deploy_dir}" do
    system "git clone #{repo_url} -b #{deploy_branch} --single-branch ."
    system "git checkout #{deploy_branch}"
  end
  puts "\n---\n## Now you can deploy to #{repo_url} with `rake deploy` ##"
end

def push(publish_task,dir,branch)
  puts "## Deploying branch to Github Pages "
  puts "## Pulling any updates from Github Pages "
  cd "#{dir}" do 
    system "git pull"
  end
  Rake::Task["generate"].execute
  Rake::Task["#{publish_task}"].execute
  cd "#{dir}" do
    system "git add -A"
    puts "\n## Committing: Site updated at #{Time.now.utc}"
    message = "Site updated at #{Time.now.utc}"
    system "git commit -m \"#{message}\""
    puts "\n## Pushing generated #{dir} website"
    system "git push origin #{branch}"
    puts "\n## Github Pages deploy complete"
  end
end

def ok_failed(condition)
  if (condition)
    puts "OK"
  else
    puts "FAILED"
  end
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def ask(message, valid_options)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end

def blog_url(user, project)
  url = if File.exists?('source/CNAME')
    "http://#{IO.read('source/CNAME').strip}"
  else
    "http://#{user}.github.io"
  end
  url += "/#{project}" unless project == ''
  url
end

def copy_directory(source,target)
  (Dir["#{target}/*"]).each { |f| rm_rf(f) }
  puts "\n## Copying #{source} to #{target}"
  cp_r "#{source}/.", target
end

desc "list tasks"
task :list do
  puts "Tasks: #{(Rake::Task.tasks - [Rake::Task[:list]]).join(', ')}"
  puts "(type rake -T for more detail)\n\n"
end
