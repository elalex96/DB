
-- p_PR_ConsultaImportacionProdPozo '53,',0,0,3
CREATE Proc p_PR_ConsultaImportacionProdPozoPrevio
@pIdsProdDiaria  varchar(1000),
@pAnio int=0,
@pMes int=0,
@pIdContrato int = 0
as


	select ID= splitdata
	into #tmpIds
	from [dbo].[fnSplitString](@pIdsProdDiaria,',')

	if(@pAnio = 0 and @pMes = 0)
	begin
		select 
		IdBloque=pd.Bloque,
		Bloque = b.Descripcion,
		IdPozo = p.Id,
		Pozo = p.Nombre,
		pozo.Fecha,
		pozo.NombreEstacion,
		pozo.Medidor,
		pozo.Nominal,
		pozo.Fuente,
		pozo.Operando,
		pozo.Est_64Plg,
		pozo.Cabeza,
		pozo.Linea,
		pozo.Temperatura,
		pozo.GastoGas,
		pozo.ProdCondensadoNeto,
		pozo.ProdAceiteNeto,
		pozo.ProdPetroleoBruto,
		pozo.Agua,
		pozo.Comentarios,
		Est_64PlgTexto = case when pozo.Est_64Plg is not null then  
								cast(((pozo.Est_64Plg * 5 ) / 0.078125 ) as varchar) + '/64'
						 else ''
						 End
							
		from PR_ProdDiariaPozo_Previo pozo
		inner join [PR_ProdDiaria_Previo]  pd on pd.ID = pozo.ProdDiaria
		inner join PR_Pozo p on p.Id = pozo.Pozo
		--inner join CO_PuntoMedicion pm on pm.IdPuntoMedicion = p.IdPuntoMedicion and
		--					pm.IdContrato = @pIdContrato
		inner join #tmpIds tmp on tmp.ID = pd.ID
		inner join PR_Bloque b on b.Id = pd.Bloque
		inner join CO_Contrato c on c.IdContrato = @pIdContrato
		inner join [dbo].[CO_AreaContractual] ac on ac.IdAreaContractual = c.IdAreaContractual
		inner join CO_Instalacion i on i.IdAreaContractual = ac.IdAreaContractual and
								i.WelIID = p.Id
	End
	Else
	BEGIN
		select 
		IdBloque=pd.Bloque,
		Bloque = b.Descripcion,
		IdPozo = p.Id,
		Pozo = p.Nombre,
		pozo.Fecha,
		pozo.NombreEstacion,
		pozo.Medidor,
		pozo.Nominal,
		pozo.Fuente,
		pozo.Operando,
		pozo.Est_64Plg,
		pozo.Cabeza,
		pozo.Linea,
		pozo.Temperatura,
		pozo.GastoGas,
		pozo.ProdCondensadoNeto,
		pozo.ProdAceiteNeto,
		pozo.ProdPetroleoBruto,
		pozo.Agua,
		pozo.Comentarios,
		Est_64PlgTexto = case when pozo.Est_64Plg is not null then  
								cast(((pozo.Est_64Plg * 5 ) / 0.078125 ) as varchar) + '/64'
						 else ''
						 End
		from PR_ProdDiariaPozo_Previo pozo
		inner join [PR_ProdDiaria_Previo]  pd on pd.ID = pozo.ProdDiaria
		inner join PR_Pozo p on p.Id = pozo.Pozo		
		inner join PR_Bloque b on b.Id = pd.Bloque
		inner join CO_Contrato c on c.IdContrato = @pIdContrato
		inner join [dbo].[CO_AreaContractual] ac on ac.IdAreaContractual = c.IdAreaContractual
		inner join CO_Instalacion i on i.IdAreaContractual = ac.IdAreaContractual and
								i.WelIID = p.Id
		WHERE DATEPART(year,pozo.Fecha) = @pAnio and
		DATEPART(month,pozo.Fecha) = @pMes 

	eND



