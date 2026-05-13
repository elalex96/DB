CREATE proc sp_Logo_Get
(
	@url	varchar(50)
)
as
begin
		
		select	@url		=	replace(@url,'http://','')
		
		select	@url		=	replace(@url,'https://','')
		
		if(CHARINDEX('/account/login.aspx',@url)>0)
		begin
			select	@url		=	substring(@url,0, CHARINDEX('/account/login.aspx',@url))
		end
		if(CHARINDEX(':',@url)>0)
		begin
			select	@url		=	substring(@url,0, CHARINDEX(':',@url))
		end
		if(CHARINDEX('.adinco',@url)>0)
		begin
			select	@url		=	substring(@url,0, CHARINDEX('.adinco',@url))
		end

		--select	@url
		
		select		--r.Ruta,
					--replace(Ruta,'.adinco.mx',''),
					top				1
					Logo			=	co.Logo 
		from		CO_Contrato		c
		inner join	CO_Contratista	co
		on			c.IdContratista	=	co.IdContratista
		inner join	AP_Rutas		r
		on			r.IdRuta		=	co.IdRuta
		where		replace(Ruta,'.adinco.mx','')	=	@url

		
end