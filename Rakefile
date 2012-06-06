require 'rake'

myDir = Dir.pwd

task :doc do
	FileList["./src/*.coffee"].each do |filename|
		system %{docco #{filename}}
	end
end

task :coffee, :watch do |t,args|
	watch = ""
	if args[:watch]
		watch = "--watch"
	end

	system %{coffee #{watch} --compile --output . src/}
end