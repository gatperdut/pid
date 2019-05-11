require 'gosu'
require './circle'

class Pid

  attr_reader :error

  def initialize(window, mob)
    @window = window
    @mob = mob

    @goal = 600

    @kp = 0.020

    @ki = 0.000005

    @kd = 0.1

    @integral_sum = 0

    set_error
  end

  def update
    set_error

    p = progressive

    i = integral

    d = derivative

    @mob.speed = p * @kp + i * @ki + d * @kd
  end

  def draw
    @window.draw_line(@goal - 1, 410, 0xFF00FF00, @goal - 1, 430, 0xFF00FF00)
    @window.draw_line(@goal + 0, 410, 0xFF00FF00, @goal + 0, 430, 0xFF00FF00)
    @window.draw_line(@goal + 1, 410, 0xFF00FF00, @goal + 1, 430, 0xFF00FF00)
  end

  private

  def set_error
    @previous_error = @error

    @error = @goal - @mob.x
  end

  def progressive
    @error
  end

  def integral
    @integral_sum = @integral_sum + @error if @error < 200 && @error > - 200

    @integral_sum
  end

  def derivative
    @error - @previous_error
  end

end

class Mob

  attr_reader :x
  attr_accessor :speed

  def initialize(window)
    @window = window

    @y = 400
    @x = 40

    @speed = 0.0

    @maxspeed = 15.0

    @circle = Gosu::Image.new(Circle.new(20))
  end

  def update
    @x = @x + @speed
  end

  def draw
    @circle.draw(@x - 20, @y - 20, -1)
  end

  private

end

class Window < Gosu::Window

  def initialize(width=1200, height=800)
    super
    self.caption = 'PID'

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    @mob = Mob.new(self)
    @pid = Pid.new(self, @mob)

    
  end

  def update
    @pid.update
    @mob.update
  end

  def button_down(id)
    close if id == Gosu::KbEscape
  end

  def needs_cursor?
    true
  end

  def needs_redraw?
    true
  end

  def draw
    draw_ground
    draw_data
    @pid.draw
    @mob.draw
  end

  private

  def draw_ground
    draw_line(20, 420, 0xFFFFFFFF, 1180, 420, 0xFFFFFFFF)
  end

  def line(l)
    20 * l
  end

  def draw_data
    @font.draw_text("Error: #{@pid.error.round(5)}", 5, line(0), 0)
    @font.draw_text("Speed: #{@mob.speed.round(5)}", 5, line(1), 0)
  end

end

window = Window.new
window.show
