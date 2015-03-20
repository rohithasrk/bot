# Description:
#   partychat like chat-score/leaderboard script built at 'SDSLabs'
#   we developed this to use in our 'Slack' team instance
#
# Commands:
#   listen for * has/have keys in chat text and displays users with the keys/updates the user having keys
#   bot who has keys : returns current user having lab keys
#   bot i have keys : set's the key-holder to the user who posted
#   bot i dont have keys : unsets the user who posted from key-holders
#	bot xyz has keys : sets xyz as the holder of keys
#
# Examples:
#   :bot who has keys
#   :bot i have keys
#   :bot i dont have keys
#	:bot who has keys
#	:bot ravi has keys
#
# Author:
#   Punit Dhoot (@pdhoot)
#   Developer at SDSLabs (@sdslabs)

module.exports = (robot)->
	getMutltipleUsers  = (users)->
		"Be more specific. I know #{users.length} people named like that #{(user.name for user in users).join(', ')}"


	key = ()->
		Key = robot.brain.get("key") or []
		robot.brain.set("key" ,Key)
		Key	

	
	robot.respond /i have (a key|the key|key|keys)/i, (msg)->
		name = msg.message.user.name 
		user = robot.brain.userForName name
		k = key()
		if typeof user is 'object'
			k[k.length] = "#{name}"
			msg.send "Okay #{name} has keys"

		robot.brain.set("key",k)	


	robot.respond /i (don\'t|dont|do not) (has|have) (the key|key|keys|a key)/i , (msg)->
		name = msg.message.user.name
		user = robot.brain.userForName name
		k = key()
		i = k.indexOf(user)
		k.splice(i, 1)
		if typeof user is 'object'
			msg.send "Okay #{name} doesn't have keys. Who got the keys then?"
		robot.brain.set("key",k)	


	robot.respond /(.+) (has|have) (the key|key|keys|a key)/i , (msg)->
		othername = msg.match[1]
		name = msg.message.user.name
		k = key()
		unless othername in ["who", "who all","Who", "Who all" , "i" , "I" , "i don't" , "i dont" , "i do not" , "I don't" , "I dont" , "I do not"]
			if othername is 'you'
				msg.send "How am I supposed to take those keys? #{name} is a liar!"
			else if othername is robot.name
				msg.send "How am I supposed to take those keys? #{name} is a liar!"
			else
				users = robot.brain.userForName(othername)
				if users.length is 1
					otheruser = users[0]
					k[k.length] = "#{otheruser.name}"
					msg.send "Ok so now the keys are with #{otheruser.name}.Take care , don't lose 'em"
					msg.send k
				else if users.length >1
					msg.send getMutltipleUsers users
				else
					msg.send "I don't know anyone by the name #{othername}"

		robot.brain.set("key",k)			

	robot.respond /(i|I) (have given|gave|had given) (the key|key|keys|a key) to (.+)/i , (msg)->
		othername = msg.match[3]
		name = msg.message.user.name
		k = key()
		if othername is 'you'
			msg.send "That's utter lies! How can you blame a bot to have the keys?"
		else if othername is robot.name
			msg.send "That's utter lies! How can you blame a bot to have the keys?"
		else
			users = robot.usersForFuzzyName(othername)
			if users.length is 1
				otheruser = users[0]
				flag = 1
				index = 0
				for u in k
					if u is name
						flag = 0
						k[index] = "#{otheruser.name}"
						break
					index++	
				if flag is 1
					k[k.length] = "#{otheruser.name}"
				msg.send "Ok so now the keys are with #{otheruser.name}.Take care , don't lose 'em"
			else if users.length > 1
				msg.send getMutltipleUsers users
			else
				msg.send "I don't know anyone by the name #{othername}"

		robot.brain.set("key",k)		
				
	robot.respond /(who|who all) (has|have) (the key|key|keys|a key)/i , (msg)->
		k = key()
		msgText = ""
		for u in k
			msgText+=u
			msgText+=" "

		if msgText is ""
			msg.send "Ah!Nobody here informed me about the keys. Don't hold me responsible for this :expressionless:"
		else
			msg.send msgText	
		robot.brain.set("key" ,k)	
