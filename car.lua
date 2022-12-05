--- Required libraries.
local Controller = require( "2DVehiclePhysics.controller" )

--- Required libraries.

-- Localised functions.
local deg = math.deg

-- Localised values.

--- Class creation.
local Car = {}

--- Initiates a new Car object.
-- @return The new Car.
function Car.new( options )

	-- Create ourselves
	local self = display.newGroup()

    for k, v in pairs( options or {} ) do
        self[ k ] = v
    end

    self._keys = {}

	self.x0 = self.x or 0
	self.y0 = self.y or 0
	self.rotation0 = self.rotation or 0

	if self.world then
		self.world:insert( self )
	end

	self._controller = Controller.new
	{
		heading = math.rad( self.rotation0 or 0 ),
		position = { x = self.x0, y = self.y0 },
		mass = 1200,
		engineForce = 1400,
		brakeForce = 4000,
		brakeActsAsReverse = true,
		airResist = 10,
		maxSteer = 0.9
	}

	self._cameraFocusPoint =
	{
		x = 0,
		y = 0,
		rotation = 0,
		zoom = 2
	}

	local scale = 3

	local bodyWidth, bodyHeight = ( self._controller.config.cgToFront + self._controller.config.cgToRear ) * scale, ( self._controller.config.halfWidth * 2.0 ) * scale
	self._body = display.newRect( self, 0, 0, bodyWidth, bodyHeight )

	self._window = display.newRect( self, bodyWidth * 0.5, 0, bodyHeight * 0.25, bodyWidth * 0.25 )
	self._window:setFillColor( 0, 0, 1 )

	local wheelWidth, wheelHeight = ( self._controller.config.wheelRadius * 2 ) * ( scale * 1.5 ), self._controller.config.wheelWidth * ( scale * 1.5 )
    self._wheels = {}
    self._wheels[ 1 ] = display.newRect( self, bodyWidth * 0.3, -bodyHeight * 0.5, wheelWidth, wheelHeight )
    self._wheels[ 1 ]:setFillColor( 1, 0, 0 )

    self._wheels[ 2 ] = display.newRect( self, bodyWidth * 0.3, bodyHeight * 0.5, wheelWidth, wheelHeight )
    self._wheels[ 2 ]:setFillColor( 1, 0, 0 )

    self._wheels[ 3 ] = display.newRect( self, -bodyWidth * 0.3, -bodyHeight * 0.5, wheelWidth, wheelHeight )
    self._wheels[ 3 ]:setFillColor( 1, 0, 0 )

    self._wheels[ 4 ] = display.newRect( self, -bodyWidth * 0.3, bodyHeight * 0.5, wheelWidth, wheelHeight )
    self._wheels[ 4 ]:setFillColor( 1, 0, 0 )

    function self.setThrottle( value )
        self._controller.inputs.throttle = value
    end

    function self.getThrottle()
        return self._controller.inputs.throttle
    end

    function self.setBrake( value )
        self._controller.inputs.brake = value
    end

    function self.getBrake()
        return self._controller.inputs.brake
    end

    function self.setHandbrake( value )
        self._controller.inputs.ebrake = value
    end

    function self.getHandbrake()
        return self._controller.inputs.ebrake
    end

    function self.setLeftSteering( value )
        self._controller.inputs.right = value
    end

    function self.getLeftSteering()
        return self._controller.inputs.right
    end

    function self.setRightSteering( value )
        self._controller.inputs.left = value
    end

    function self.getRightSteering()
        return self._controller.inputs.left
    end

	function self.getSpeed()
		return self._controller.getSpeed()
	end

	function self.getHeading( degrees )
		return self._controller.getHeading( degrees )
	end

	function self.getMaxSteer( degrees )
		return self._controller.getMaxSteer( degrees )
	end

	function self.getCameraFocus()

		local angle = self.rotation + 90

		angle = angle - ( self.getLeftSteering() * ( self.getMaxSteer( true ) * 0.5 ) )
		angle = angle + ( self.getRightSteering() * ( self.getMaxSteer( true ) * 0.5 ) )

		local vector = { x = math.cos( math.rad( angle - 90 ) ), y = math.sin( math.rad( angle - 90 ) ) }

		local lookAheadDistance = 70 * 0.5

		local lookAheadFactor = ( ( ( self.getSpeed() - 0 ) * ( 1 - 0 ) ) / ( lookAheadDistance - 0 ) ) + 0

		self._cameraFocusPoint.x = self.x
		self._cameraFocusPoint.y = self.y
		self._cameraFocusPoint.rotation = math.deg( math.atan2( self.y, self.x ) - math.atan2( display.contentCenterY, display.contentCenterX ) )

		if self._cameraFocusPoint.rotation < -360 then
			self._cameraFocusPoint.rotation = focus.rotation + 360
		elseif self._cameraFocusPoint.rotation > 360 then
			self._cameraFocusPoint.rotation = focus.rotation - 360
		end

		return self._cameraFocusPoint

	end

    function self.enterFrame( event )

		---[[
		if self.controls then
	        self.setThrottle( self._keys[ self.controls[ "go" ] ] and 1 or 0 )
	        self.setBrake( self._keys[ self.controls[ "stop" ] ] and 1 or 0 )
	        self.setHandbrake( self._keys[ self.controls[ "reallyStop" ] ] and 1 or 0 )
	        self.setLeftSteering( self._keys[ self.controls[ "left" ] ] and 1 or 0 )
	        self.setRightSteering( self._keys[ self.controls[ "right" ] ] and 1 or 0 )

			if self._keys[ self.controls[ "zoomOut" ] ] then
				self._cameraFocusPoint.zoom = self._cameraFocusPoint.zoom - 0.01
			elseif self._keys[ self.controls[ "zoomIn" ] ] then
				self._cameraFocusPoint.zoom = self._cameraFocusPoint.zoom + 0.01
			end
		end
		--]]

        self._controller.update( 1 )

        self.x = self.x0 + self._controller.position.x
        self.y = self.y0 + self._controller.position.y

        self._wheels[ 1 ].rotation = math.deg( self._controller.steerAngle )
        self._wheels[ 2 ].rotation = math.deg( self._controller.steerAngle )

        self.rotation = deg( self._controller.heading )

    end

    function self.key( event )
        self._keys[ event.keyName ] = event.phase == "down"
    end

    Runtime:addEventListener( "enterFrame", self.enterFrame )
    Runtime:addEventListener( "key", self.key )

	if options.parent then
		options.parent:insert( self )
	end

    -- Return the Car object
	return self

end

return Car
