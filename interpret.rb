require './brainfuck'
bf = Brainfuck.new
debug = false
loop do
  begin
    print "code> "
    input = gets.chomp
    args = input.split
    case (args.shift || '').to_sym
    when :reset
      bf = Brainfuck.new
    when :max
      bf = Brainfuck.new(args.shift.to_i)
    when :nomax
      bf = Brainfuck.new(nil)
    when :debug
      debug = !debug
      puts "debug: o#{debug ? 'n' : 'ff'}"
    when :set
      idx = args.shift.to_i
      val = args.shift.to_i
      bf.array[idx] = val
    else
      bf.code << input
      bf.run(debug)
    end
    p bf
  rescue Brainfuck::Exception => e
    puts e.class.name
  end
end