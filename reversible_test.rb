require 'dxruby'

# 盤の設定
WINDOW_WIDTH = 400
#WINDOW_WIDTH = 600
WINDOW_HEIGHT = 400
BOARD_SIZE = 8
CELL_SIZE = WINDOW_WIDTH / BOARD_SIZE
#CELL_SIZE = (WINDOW_WIDTH - 200) / BOARD_SIZE
BOARD_OFFSET_X = 100

# ゲームの初期化
def initialize_game
  # 盤の作成
  @board = Array.new(BOARD_SIZE) { Array.new(BOARD_SIZE, :empty) }

  # 初期の盤設定
  @board[3][3] = :white
  @board[3][4] = :black
  @board[4][3] = :black
  @board[4][4] = :white

  # 先手の駒を設定
  @current_player = :black
end

# 指定されたプレーヤーに有効な手があるかどうかをチェック
def valid_moves_exist?(player)
  (0...BOARD_SIZE).each do |y|
    (0...BOARD_SIZE).each do |x|
      return true if valid_move?(x, y, player)
    end
  end

  return false
end

# 現在のプレイヤーに有効な手かどうかをチェック
def valid_move?(x, y, player)
  return false if @board[y][x] != :empty

  opponent = (player == :black) ? :white : :black

  # 隣接する相手の駒が1枚以上あるかどうか、
  # 反転できる相手の駒の並びがあるかどうかを確認する
  directions = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]

  directions.each do |dir_x, dir_y|
    curr_x = x + dir_x
    curr_y = y + dir_y
    found_opponent = false

    while in_bounds?(curr_x, curr_y)
      if @board[curr_y][curr_x] == opponent
        found_opponent = true
      elsif @board[curr_y][curr_x] == player
        return true if found_opponent
        break
      else
        break
      end

      curr_x += dir_x
      curr_y += dir_y
    end
  end

  return false
end

# ゲームボードに駒を置く
def place_piece(x, y, player)
  @board[y][x] = player
end

# 相手の駒を裏返す
def flip_pieces(x, y, player)
  opponent = (player == :black) ? :white : :black

  directions = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]

  directions.each do |dir_x, dir_y|
    curr_x = x + dir_x
    curr_y = y + dir_y
    found_opponent = false

    while in_bounds?(curr_x, curr_y)
      if @board[curr_y][curr_x] == opponent
        found_opponent = true
      elsif @board[curr_y][curr_x] == player
        if found_opponent
          # 駒を挟んで反転
          flip_direction(x, y, dir_x, dir_y)
        end
        break
      else
        break
      end

      curr_x += dir_x
      curr_y += dir_y
    end
  end
end

# 駒を特定の方向に反転
def flip_direction(x, y, dir_x, dir_y)
  curr_x = x + dir_x
  curr_y = y + dir_y

  while @board[curr_y][curr_x] != @current_player
    @board[curr_y][curr_x] = @current_player
    curr_x += dir_x
    curr_y += dir_y
  end
end

# 次のプレーヤーに切り替える
def switch_player
  @current_player = (@current_player == :black) ? :white : :black
end

# 座標がゲームボード内にあるかどうかをチェック
def in_bounds?(x, y)
  x >= 0 && x < BOARD_SIZE && y >= 0 && y < BOARD_SIZE
end

# ゲームボードを描く
def draw_board
  Window.draw_box_fill(BOARD_OFFSET_X, 0, BOARD_OFFSET_X + BOARD_SIZE * CELL_SIZE, WINDOW_HEIGHT, [0, 128, 0])
  @board.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      draw_cell(x, y, cell)
    end
  end
end

# ゲームボードにセルを描く
def draw_cell(x, y, cell)
  x_pos = x * CELL_SIZE
  y_pos = y * CELL_SIZE
  radius = CELL_SIZE/2
  x_cen_pos = x_pos + radius
  y_cen_pos = y_pos + radius
  
  case cell
  when :black
    color_1 = [0,128,64]
    color_2 = [40, 220, 240]
    color_3 = [0, 0, 0]
  when :white
    color_1 = [0,128,64]
    color_2 = [40, 220, 240]
    color_3 = [255, 255, 255]
  else
    color_1 = [0,128,64]
    color_2 = [40, 220, 240]
    color_3 = [0,128,64]
  end

  Window.draw_box_fill(x_pos, y_pos, x_pos + CELL_SIZE, y_pos + CELL_SIZE, color_1)
  Window.draw_box(x_pos, y_pos, x_pos + CELL_SIZE, y_pos + CELL_SIZE, color_2)
  Window.draw_circle_fill(x_cen_pos,y_cen_pos,radius,color_3)

end

# def pass(player)
#   font = Font.new(48)
#   Window.draw_font(WINDOW_WIDTH / 2 - 125, WINDOW_HEIGHT / 2 - 24, "#{player}をパス", font,[255,0,0])
# end

def game_over
  font = Font.new(48)
  Window.draw_font(WINDOW_WIDTH / 2 - 125, WINDOW_HEIGHT / 2 - 24, "Game Over!!", font, color: [255, 0, 0])
end

# ゲームの Main loop
Window.width = WINDOW_WIDTH
Window.height = WINDOW_HEIGHT
Window.bgcolor = [255,0,128,0]

initialize_game

screen_point = 0

Window.loop do
  # 画面をクリアにする
  Window.draw_box_fill(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, [0, 128, 0])

  # ゲームボードを描く
  draw_board

  # クリック入力
  if Input.mouse_push?(M_LBUTTON)
    # マウス位置からセル座標を算出
    x = Input.mouse_pos_x / CELL_SIZE
    y = Input.mouse_pos_y / CELL_SIZE

    # 選択されたセルが現在のプレーヤーに対して有効かどうかをチェック
    if valid_move?(x, y, @current_player)
      # 選択したセルに駒を置く
      place_piece(x, y, @current_player)

      # 相手の駒を裏返す
      flip_pieces(x, y, @current_player)

      # 有効な手があれば次のプレイヤーに交代
      if valid_moves_exist?(@current_player == :black ? :white : :black)
        switch_player
      elsif valid_moves_exist?(@current_player)
        puts "#{@current_player == :black ? :white : :black}に有効な手がありません! 手番をスキップします。"
      else
        screen_point = 1
        puts "Game Over!"
      end
    end
  end

  if screen_point == 1
    game_over
  end

  # ウィンドウをアップデート
  #Window.update
end
    