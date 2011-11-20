class Brainfuck
  class Exception < ::Exception; end
  class NegativePointerException < Exception; end

  attr_reader :max, :array, :code, :input, :output, :count
  attr_accessor :arrayp, :codep, :inputp

  def initialize(max=256)
    @max      = max
    @array    = [0]
    @arrayp   = 0
    @code     = ""
    @codep    = 0
    @input    = []
    @inputp   = 0
    @output   = []
    @count    = 0
  end

  def run_one_instruction(debug)
    show_debug_info if debug && "><+-.,[]".include?(@code[@codep])

    case @code[@codep]
    when ">"
      @arrayp += 1
      @array[@arrayp] = 0 if @array[@arrayp].nil?
    when "<"
      @arrayp -= 1
      raise NegativePointerException if @arrayp < 0
    when "+"
      @array[@arrayp] += 1
      @array[@arrayp] %= @max if @max
    when "-"
      @array[@arrayp] -= 1
      @array[@arrayp] %= @max if @max
    when "."
      @output << @array[@arrayp]
    when ","
      @array[@arrayp] = @input.getbyte(@inputp)
      @inputp += 1
    when "["
      if @array[@arrayp] == 0
        brackets = 1
        until brackets == 0
          @codep += 1
          brackets += 1 if @code[@codep] == "["
          brackets -= 1 if @code[@codep] == "]"
        end
      end
    when "]"
      unless @array[@arrayp] == 0
        brackets = 1
        until brackets == 0
          @codep -= 1
          brackets += 1 if @code[@codep] == "]"
          brackets -= 1 if @code[@codep] == "["
        end
      end
    end

    @count += 1 if "><+-.,[]".include?(@code[@codep])
    @codep += 1
  end

  def run(debug=false)
    loop do
      break if @codep >= @code.size

      run_one_instruction(debug)
    end

    self
  end

  def inspect
    "#<#{self.class} array=#{@array.inspect} " +
    "code=#{self.class.remove_irrelevent_characters(@code).inspect} " +
    "input=#{@input.inspect} output=#{@output.inspect} pointers: { " +
    "array=#{@arrayp} code=#{@codep} input=#{@inputp} } max=#{@max} " +
    "count=#{@count}>"
  end

  def self.remove_irrelevent_characters(str)
    str.each_char.select { |c| "><+-.,[]".include?(c) }.join
  end

  def self.run(code, debug=false)
    bf = new
    bf.code << code
    bf.run(debug)
  end

  protected

  def debug_info
    str = ""
    str += highlight(@array.map(&:to_s), @arrayp).join(" ") + "\n"
    str += "ptrs: array=#{@arrayp} code=#{@codep} input=#{@inputp}\n"
    str += "count=#{@count}\n"
    unless @output.empty?
      str += "output: #{@output.inspect}\n"
      str += "output: #{@output.map(&:chr).join.inspect}\n"
    end
    str += "input: #{@input.inspect}\n" unless @input.empty?
    str += highlight(@code, @codep) + "\n"
  end

  def show_debug_info
    print "\e[H" + debug_info.gsub("\n", "\e[K\n") + "\e[J"
    gets
  end

  def highlight(o, i)
    o = o.dup
    o[i] = invert(o[i])
    o
  end

  def invert(o)
    "\e[7m#{o}\e[m"
  end
end

if $0 == __FILE__
  Brainfuck.run(ARGF.read, true)
end
