--Configuration (i.e. window size and other variables)
function love.conf(t)
  t.title = "Scrolling Tutorial"
  t.version = "0.9.1"
  t.window.width = 680
  t.window.height = 800
  
  --For the Windows bug squashing
  t.console = true
end