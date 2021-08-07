# simple build file to be used locally by Sam
#
require 'pty'
require 'optparse'

images = {
  base: { name: 'base', tag: "bamzooka/base:build", squash: true },
  bamzooka_test_build: { name: 'bamzooka_test', tag: "bamzooka/bamzooka_test:build", squash: false},
  bamzooka_test_public: { name: 'bamzooka_test', tag: "bamzooka/bamzooka_test:release", squash: true, extra_args: ' --build-arg tag=release '},
  bamzooka_dev: { name: 'bamzooka_dev', tag: "bamzooka/bamzooka_dev:build", squash: false },
}

def run(command)
  lines = []
  PTY.spawn(command) do |stdin, stdout, pid|
    begin
      stdin.each do |line|
        lines << line
        puts line
      end
    rescue Errno::EIO
      # we are done
    end
  end

  lines
end

def build(image)
  lines = run("cd #{image[:name]} && docker build . --no-cache --tag #{image[:tag]} #{image[:squash] ? '--squash' : ''} #{image[:extra_args] ? image[:extra_args] : ''}")
  raise "Error building the image for #{image[:name]}: #{lines[-1]}" if lines[-1] =~ /successfully built/
end

def dev_deps()
  run("sed -e 's/\(db_name: bamzooka\)/\1_development/' ../templates/postgres.template.yml > bamzooka_dev/postgres.template.yml")
  run("cp ../templates/redis.template.yml bamzooka_dev/redis.template.yml")
end

image = ARGV[0].intern
raise 'Image not found' unless images.include?(image)

puts "Building #{images[image]}"
dev_deps() if image == :bamzooka_dev

build(images[image])
