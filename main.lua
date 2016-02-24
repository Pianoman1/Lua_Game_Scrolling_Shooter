Debug = true


--****Timers****--
--Player
canShoot = true
canShootTimerMax = 0.02
canShootTimer = canShootTimerMax
--Enemy
createEnemyTimerMax = 0.4
createEnemyTimer = createEnemyTimerMax
  
  
--****Image Storage****--
--Player
bulletImg = nil
hitImg = nil
--Enemy
enemyImg = nil -- Like other images we'll pull this in during our love.load function


--****Array Storage****--
--Player
bullets = {} --array of current bullets being drawn and updated
--Enemy
enemies = {} -- array of current enemies on screen


-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end


--player = nil -- this is just for storage
Player = 
      {
        x = 200,
        y = 710,
        speed = 350,
        image = nil
      }  
isAlive = true
isHit = false
starthealth = 50
health = starthealth
score = 0


function love.load(arg)
  --Player
  Player.image = love.graphics.newImage('assets/BAM.png')
  bulletImg = love.graphics.newImage('assets/Orange.png')
  hitImg = love.graphics.newImage('assets/HitShip.png')
  --Enemy
  enemyImg = love.graphics.newImage('assets/BkAM.png')
end

-- Updating
function love.update(dt)
  
  
  --****Controls****--
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end
  if love.keyboard.isDown('left', 'a') then
    if Player.x > 0 then
      Player.x = Player.x - (Player.speed*dt)
    end
  elseif love.keyboard.isDown('right', 'd') then
    if Player.x < (love.graphics.getWidth() - Player.image:getWidth()) then
      Player.x = Player.x + (Player.speed*dt)
    end 
  end
  if love.keyboard.isDown('up', 'w') then
    --if Player.y > (love.graphics.getHeight() - 8*Player.image:getHeight()) then
      if Player.y > (love.graphics.getHeight()/2) then
      Player.y = Player.y - (Player.speed*dt)
    end
  elseif love.keyboard.isDown('down', 's') then
    if Player.y < (love.graphics.getHeight() - Player.image:getHeight()) then
      Player.y = Player.y + (Player.speed*dt)
    end 
  end
  
  
  --****Timers****--
  --Player
  canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end
  --If bullet is shot
  if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') and canShoot then
  --if love.keyboard.isDown(' ', 'rctrl', 'lctrl', 'ctrl') then
	  -- Create some bullets
	  newBullet = { x = Player.x + (Player.image:getWidth()/2) - 5, y = Player.y, image = bulletImg }
	  --newBullet = { x = Player.x + 7, y = Player.y, image = bulletImg }
	  table.insert(bullets, newBullet)
	  canShoot = false
	  canShootTimer = canShootTimerMax
  end
  
  --Enemy
  createEnemyTimer = createEnemyTimer - (1 * dt)
  if createEnemyTimer < 0 then
   	createEnemyTimer = createEnemyTimerMax

	  -- Create an enemy
  	randomNumber = math.random(10, love.graphics.getWidth() - 10)
	  newEnemy = { x = randomNumber, y = -10, image = enemyImg }
	  table.insert(enemies, newEnemy)
  end


  --****Image Updates****--
  --Player
  for i, bullet in ipairs(bullets) do
  	bullet.y = bullet.y - (250 * dt)

  	if bullet.y < 0 then -- remove bullets when they pass off the screen
		table.remove(bullets, i)
	  end
  end
  
  --Enemy
  for i, enemy in ipairs(enemies) do
  	enemy.y = enemy.y + (200 * dt)

  	if enemy.y > 850 then -- remove enemies when they pass off the screen
	  	table.remove(enemies, i)
  	end
  end
  
  -- run our collision detection
  -- Since there will be fewer enemies on screen than bullets we'll loop them first
  -- Also, we need to see if the enemies hit our player
  for i, enemy in ipairs(enemies) do
  	for j, bullet in ipairs(bullets) do
	  	if CheckCollision(enemy.x, enemy.y, enemy.image:getWidth(), enemy.image:getHeight(), bullet.x, bullet.y, bullet.image:getWidth(), bullet.image:getHeight()) then
		  	table.remove(bullets, j)
		  	table.remove(enemies, i)
		  	score = score + 1
		  end
	  end

  	if CheckCollision(enemy.x, enemy.y, enemy.image:getWidth(), enemy.image:getHeight(), Player.x + 25, Player.y, Player.image:getWidth()/2, Player.image:getHeight() - 50) then
      table.remove(enemies, i)
	  	health = health - 5
      isHit = true
    end
    if health == 0 then
	  	table.remove(enemies, i)
	  	isAlive = false
	  end
  end  

  if not isAlive and love.keyboard.isDown('r') then
  	-- remove all our bullets and enemies from screen
  	bullets = {}
  	enemies = {}

	  -- reset timers
	  canShootTimer = canShootTimerMax
	  createEnemyTimer = createEnemyTimerMax

  	-- move player back to default position
  	Player.x = 50
  	Player.y = 710

  	-- reset our game state
  	score = 0
  	isAlive = true
    health = starthealth
  end

end

function love.draw(dt)
  --Player
  if isAlive then
  	love.graphics.draw(Player.image, Player.x, Player.y)
  else
	  love.graphics.print("You dead. Hit the R button for another ass-whoopin", 43, love.graphics:getHeight()/2-10)
  end
  for i, bullet in ipairs(bullets) do
  love.graphics.draw(bullet.image, bullet.x, bullet.y)
  end
  --Enemy
  for i, enemy in ipairs(enemies) do
  	love.graphics.draw(enemy.image, enemy.x, enemy.y)
  end  
  if isHit then
  	love.graphics.draw(hitImg, Player.x, Player.y)
    isHit = false
  end  
  love.graphics.print("Score: " ..score.. "", 50,50)
  love.graphics.print("Health: " ..health.. "", 50,70)
end
