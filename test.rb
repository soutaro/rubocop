def f
  foo or return nil
  foo and return false
end

def g
  foo or bar
  foo and bar
end

def h
  foo or 3
  foo and []
end
