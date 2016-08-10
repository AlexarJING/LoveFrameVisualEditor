local ui={}
ui.createTag="none"
ui.create={}
ui.create.base=loveframes.Create("frame")
	:SetName("Frame")
	:SetPos(20,20)
	:SetDockable(true)
	:SetName("create object")
	:ShowCloseButton(false)
	:SetSize(200,500)
ui.listPosX=500
ui.listPosY=20
ui.t=0
ui.resize=false
local createObj={
	"frame","button","checkbox","collapsiblecategory","columnlist",
	"form","grid","image","imagebutton","list","menu",
	"multichoice","numberbox","panel","progressbar","radiobutton",
	"slider","tabs","text","textinput","tree"
}

for i,v in ipairs(createObj) do
	ui.create[v]=loveframes.Create("button",ui.create.base)
	local button = ui.create[v]
	:SetText(v)
	:SetPos(5+100*((i+1)%2),5+math.ceil(i/2)*40)
	:SetSize(90,30)
	:SetEnabled(false)
	button.OnClick = function(object)
    	ui.createTag=v
	end
end

ui.create.frame:SetEnabled(true)
print(ui.create.frame.OnClick)
ui.create.frame.OnClick=function(obj)
	ui.createTag="frame"
	for k,v in pairs(ui.create) do
		if v.SetEnabled then
			v:SetEnabled(true)
		end
	end
end
ui.target={}

function ui:refreshList()
	if not self.property then return end
	local obj=self.property.obj
	self:createList(obj)
end

function ui:createList(obj)
	if self.property then 
		self.listPosX=self.property.base:GetX()
		self.listPosY=self.property.base:GetY()
		self.property.base:Remove() 
		self.property.list:Remove()
	end
	self.property={}
	self.property.obj=obj
	self.property.base=loveframes.Create("frame")
		:SetName("Frame")
		:SetPos(self.listPosX,self.listPosY)
		:SetName("property")
		:ShowCloseButton(false)
		:SetSize(220,500)
	self.property.list=loveframes.Create("columnlist", self.property.base)
	:AddColumn("Key")
	:AddColumn("Value")
	:SetPos(1,50)
	:SetSize(220,500)

	for k, v in pairs(obj) do
		if type(v)~="function" then
			if k=="internals" then
				self.property.list:AddRow(k,#v)
				for i,obj in ipairs(v) do
					for k,v in pairs(obj) do
						self.property.list:AddRow(obj.type.."-"..k, tostring(v))
					end
				end
				
			else
				self.property.list:AddRow(k, tostring(v))
			end
		end
	end
	self.property.list.OnRowClicked = function(parent, row, rowdata)
		self:editProperty(obj,rowdata[1],rowdata[2])
	end
end

function ui:editProperty(obj,key,value)
	local frame = loveframes.Create("frame")
	frame:SetName(key.."--edit mode")
	frame:SetSize(500, 90)
	frame:CenterWithinArea(0,0,800,600)
	
	local textinput = loveframes.Create("textinput", frame)
	textinput:SetPos(5, 30)
	textinput:SetWidth(490)
	textinput:SetText(value)
	textinput.OnEnter = function(object)
		local t=type(obj[key])
		if t=="number" then
			obj[key]=tonumber(textinput:GetText())
		elseif t=="string" then
			obj[key]=textinput:GetText()
		elseif t=="boolean" then
			obj[key]= textinput:GetText()=="true"
		else
			print("not support edit type")
		end
		frame:Remove()
		ui:refreshList()
	end
end


function ui:mousepressed(x,y,key)
	if x<100 or y<100 or x>800 or y>600 then return end
	if #self.target==0 then return end
	if key=="l" then
		for i=1,#self.target do
			if self.target[i]:GetHover() then
				self.selectObj=self.target[i]
				self:createList(self.selectObj)
			end
		end
	end
end

function ui:keypressed(key)
	if key=="escape" then
		self.selectObj=nil
	elseif key=="delete" and self.selectObj then
		table.removeItem(self.target,self.selectObj)
		self.selectObj:Remove()
		self.selectObj=nil
		if self.property then 
			self.property.base:Remove() 
			self.property.list:Remove()
		end
	end
end

function ui:objDrag()
	if self.createTag~="none" then return end
	local x, y = love.mouse.getPosition()
	if love.mouse.isDown("l") and self.selectObj and self.selectObj:GetHover() then
		
		
		if not self.dragLX then
			self.dragLX,self.dragLY=x-self.selectObj:GetX(),y-self.selectObj:GetY()
			if self.selectObj:GetWidth()-self.dragLX<10 and self.selectObj:GetHeight()-self.dragLY<10 then
				self.resize=true
			end
		end
		local p=self.selectObj:GetParent()
		if not self.resize then
			if tostring(p)~="instance of class loveframes_object_base" then
				local px,py=p:GetX(),p:GetY()
				self.selectObj:SetPos(x-self.dragLX-px,y-self.dragLY-py)
				self:refreshList()
				return
			else
				self.selectObj:SetPos(x-self.dragLX,y-self.dragLY)
				self:refreshList()
				return
			end
		end
	end
	if love.mouse.isDown("l") and self.resize then 
		local p=self.selectObj:GetParent()
		local o=self.selectObj
		local ox,oy=o:GetX(),o:GetY()
		if tostring(p)~="instance of class loveframes_object_base" then
			self.selectObj:SetSize(x-ox,y-oy)
			self:refreshList()
			return
		else
			
			self.selectObj:SetSize(x-ox,y-oy)
			self:refreshList()
			return
		end
	end

	self.resize=false
	self.dragLX=nil
end

function ui:update(dt)
	self:objDrag()
	loveframes.update(dt)
	local x, y = love.mouse.getPosition()
	if x<100 or y<100 or x>800 or y>600 then return end
	if ui.createTag~="none" then ui.createCX,ui.createCY = love.mouse.getPosition() end
	local down = love.mouse.isDown("l") 
	if ui.createTag~="none" then
		if not ui.createOX and down then
			ui.createOX,ui.createOY = love.mouse.getPosition()
		end
		if ui.createOX and not down then
			--create
			local object
			if ui.createTag=="frame" then
				object=loveframes.Create(ui.createTag)
					:SetPos(ui.createOX,ui.createOY)
					:SetSize(math.abs(ui.createOX-ui.createCX),math.abs(ui.createOY-ui.createCY))
				ui.createBase=object
			else
				local base=ui.createBase
				object=loveframes.Create(ui.createTag,base)
						:SetPos(ui.createOX-base:GetX(),ui.createOY-base:GetY())
						:SetSize(math.abs(ui.createOX-ui.createCX),math.abs(ui.createOY-ui.createCY))
				if object.SetText then object:SetText(ui.createTag) end
			end

			self:createList(object)
			table.insert(self.target,object)
			ui.createTag="none"
			ui.createOX=nil
			ui.createOY=nil
		end
	end

end

local help=[[
	1. press create button to create things
	2. drag the objects to change to location
	3. drag at the right down edge to resize
	4. click at property sheet to edit the value
	5. save and import are not supported at moment
]]

function ui:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(help,300,100)
	loveframes.draw()
	self.t=self.t+math.pi/100
	love.graphics.setColor(255*math.sin(self.t), 255*math.cos(self.t),0)
	if ui.createOX then
		love.graphics.rectangle("line", ui.createOX,ui.createOY, math.abs(ui.createOX-ui.createCX),math.abs(ui.createOY-ui.createCY))
	end
	if self.selectObj then
		love.graphics.rectangle("line",self.selectObj:GetX(),self.selectObj:GetY(),self.selectObj:GetWidth(),self.selectObj:GetHeight())
	end
end


return ui