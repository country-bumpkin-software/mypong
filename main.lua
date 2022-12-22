push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200


function love.load()
    scoreSound = love.audio.newSource("sounds/score.wav", "static")
    wallHitSound = love.audio.newSource("sounds/wall_hit.wav", "static")
    paddleHitSound = love.audio.newSource("sounds/paddle_hit.wav", "static")
    love.graphics.setDefaultFilter("nearest","nearest")
    
    math.randomseed(os.time())
    smallFont = love.graphics.newFont("font.ttf", 8)
    scoreFont = love.graphics.newFont("font.ttf", 32)
    love.graphics.setFont(smallFont)
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,{
        fullscreen = false,
        resizable = false,
        vsync = true,
    })
    love.window.setTitle("retro pong")
    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH -10, VIRTUAL_HEIGHT -30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH/2 -2, VIRTUAL_HEIGHT/2 -2, 4,4)


    gameState = 'start'

end

function love.draw()
    push:apply('start')
    love.graphics.clear(0.40,0.45,0.53,255)
    love.graphics.setFont(smallFont)
    love.graphics.printf("Hello Pong!", 0, 20, VIRTUAL_WIDTH, "center")
    
    -- draw score
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2 -50, VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2 +30, VIRTUAL_HEIGHT/3)
    -- player 1 paddle
    love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)
    -- player 2 paddle
    love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)
    -- ball
    love.graphics.rectangle('fill',ball.x,ball.y, ball.width,ball.height)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10,10)
    push:apply('end')
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'return' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'
            -- reinitialise the ball
            ball:reset()
        end
    end
end


function love.update(dt)

    if ball.y <= 0 then 
        love.audio.play(wallHitSound)
        ball.y = 0
        ball.dy = -ball.dy
    end
    if ball.y >= VIRTUAL_HEIGHT -4 then
        love.audio.play(wallHitSound)
        ball.y = VIRTUAL_HEIGHT -4
        ball.dy = -ball.dy
    end

    
    -- player 1 move
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else 
        player1.dy = 0
    end

    -- player 2 move
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else 
        player2.dy = 0
    end

    if gameState=='play' then
        ball:update(dt)
        if ball:collide(player1) then
            ball.dx = -ball.dx * 1.1
            ball.x = player1.x + 5
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end
        if ball:collide(player2) then
            ball.dx = -ball.dx * 1.1
            ball.x = player2.x - 4
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end
        if ball:out() then
            gameState = 'start'
            ball:reset()
        end
    end
    player1:update(dt)
    player2:update(dt)
end

