local function Rotate( str, num )
	return ( str:gsub( ".", function( char )
		local byte = char:byte( ) + num;
		while byte < 0 do
			byte = 255 + byte;
    end
		while byte > 255 do
			byte = byte - 255;
		end
		return string.char( byte );
	end ) );
end

function string:encrypt( code )
	return Rotate( self, code or 20 );
end

function string:decrypt( code )
	return Rotate( self, code or -20 );
end
