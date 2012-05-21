require 'pathname'
require 'fileutils'
require 'json'

namespace :hqmf do

  desc 'Open a console for interacting with parsed HQMF'
  task :console do
    
    def load_hqmf(id)
      HQMF1::Document.new(File.expand_path(File.join(".","test","fixtures","NQF_Retooled_Measure_#{id}.xml")))
    end
    
    Pry.start
  end

  desc 'Parse all xml files to JSON and save them to /tmp'
  task :parse_all, [:path, :version] do |t, args|
    
    raise "You must specify the HQMF XML file path to convert" unless args.path
    
    FileUtils.mkdir_p File.join(".","tmp",'json')
    path = File.expand_path(args.path)
    version = args.version || HQMF::Parser::HQMF_VERSION_1
    
    Dir.glob(File.join(path,'*.xml')) do |measure_def|
      puts "processing #{measure_def}..."
      doc = HQMF::Parser.parse(File.open(measure_def).read, version)
      filename = Pathname.new(measure_def).basename
      
      File.open(File.join(".","tmp",'json',"#{filename}.json"), 'w') {|f| f.write(doc.to_json.to_json) }
    end
    
  end

  desc 'Parse specified xml file to JSON and save it to /tmp'
  task :parse, [:file,:version] do |t, args|
    FileUtils.mkdir_p File.join(".","tmp",'json')
    
    raise "You must specify the HQMF XML file to convert" unless args.file
    
    version = args.version || HQMF::Parser::HQMF_VERSION_1
    file = File.expand_path(args.file)
    filename = Pathname.new(file).basename
    
    doc = HQMF::Parser.parse(File.open(file).read, version)
    outfile = File.join(".","tmp",'json',"#{filename}.json")
    File.open(outfile, 'w') {|f| f.write(doc.to_json.to_json(max_nesting: 100).gsub(/",/,"\",\n")) }
    
    puts "wrote result to: #{outfile}"
    
  end
  
  desc 'Parse specified xml file to V1 JSON and save it to /tmp'
  task :parse_v1, [:file] do |t, args|
    FileUtils.mkdir_p File.join(".","tmp",'json')
    
    raise "You must specify the HQMF XML file to convert" unless args.file
    
    file = File.expand_path(args.file)
    filename = Pathname.new(file).basename
    
    doc = HQMF1::Document.new(File.open(file).read).to_json
    outfile = File.join(".","tmp",'json',"#{filename}_v1.json")
    File.open(outfile, 'w') {|f| f.write(doc.to_json(max_nesting: 100).gsub(/",/,"\",\n")) }
    puts "wrote result to: #{outfile}"
    
  end

  desc 'Convert V1 JSON to V2 JSON and save it to /tmp'
  task :convert, [:file] do |t, args|
    FileUtils.mkdir_p File.join(".","tmp",'json')
    
    raise "You must specify the V1 JSON file to convert" unless args.file
    
    file = File.expand_path(args.file)
    filename = Pathname.new(file).basename

    converted = HQMF::DocumentConverter.convert(JSON.parse(File.open(file).read,:symbolize_names => true))
    
    outfile = File.join(".","tmp",'json',"#{filename}_v2.json")
    File.open(outfile, 'w') {|f| f.write(converted.to_json.to_json.gsub(/",/,"\",\n")) }
    puts "wrote result to: #{outfile}"
    
  end
  

  
end