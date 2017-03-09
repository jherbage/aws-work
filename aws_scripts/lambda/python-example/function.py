puts 'Loading event'

def handler(event, context): 
  obj={}
  obj.name = event.name if event.name is not None else 'No-name'
  puts '"Hello":"' + obj.name + '"'
  return obj           
