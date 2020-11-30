

CREATE proc [dbo].[p_CmbAnioMes]
as

	declare @i int = 0,
		@fechaAux DateTime,
		@fechaIndex datetime,
		@mes int

	create table #tmpAnioMes
	(
		AnioMesId int,
		fechaId DateTime,
		AnioMes varchar(250)		
	)

	
	set @fechaIndex = dateadd(day ,
						- (datepart(day,getdate()) -1)
					,getdate())

	while @i <= 100
	begin		
		
		select @fechaAux = @fechaIndex,
				@mes = datepart(month,@fechaAux)				

		insert into #tmpAnioMes
		select 
			(datepart(year,@fechaAux) * 100) + datepart(MONTH,@fechaAux),
			 DATEADD(dd, DATEDIFF(dd, 0, @fechaAux), 0), 
			case 
				when @mes = 1 then 'Enero'
				when @mes = 2 then 'Febrero'
				when @mes = 3 then 'Marzo'
				when @mes = 4 then 'Abril'
				when @mes = 5 then 'Mayo'
				when @mes = 6 then 'Junio'
				when @mes = 7 then 'Julio'				
				when @mes = 8 then 'Agosto'
				when @mes = 9 then 'Septiembre'
				when @mes = 10 then 'Octubre'
				when @mes = 11 then 'Noviembre'
				when @mes = 12 then 'Diciembre'
			end + ' ' +  cast(datepart(year,@fechaAux) as varchar)

		set @i = @i + 1
		select @fechaIndex = dateadd(month,-1,@fechaAux)

	end

	select * from #tmpAnioMes
	order by fechaId desc

	


