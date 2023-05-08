-- =============================================
-- Author:		Reyna O.
-- Create date: 13/02/2018
-- Description: Realiza calculo para la nominacion de acuerdo a la unidad de medicion
-- =============================================
CREATE PROCEDURE [dbo].[CalculoReporteNominacionMensual]
	-- Add the parameters for the stored procedure here
	
@idContrato int,
@idProductoNominacion int,
@puntoEntrega int,
@FechaMesAnio nvarchar(Max)
	--Exec [CalculoReporteNominacionMensual] 10024,1000,1004,'2018-02-01'
	--Exec [CalculoReporteNominacionMensual] 10017,10014,1000,1000,2,2018,1000
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		Declare @diasCalendario int,
		@dias int,
		@unidadMedida int,
		@mes int,
		@anio int;
	----
	
	Select @mes= Month(@FechaMesAnio);
	Select @anio= Year(@FechaMesAnio);

		SET LANGUAGE Spanish;
		--Cuenta los dias del mes para ese Año
		Select @diasCalendario= Count(idFecha)  from ap_Calendario
		 where month(idFecha)=@mes and year (idFecha)=@anio 

		 --Extrae la unidad de medida para saber si se realizara una conversion 
		 Select  Top 1 @unidadMedida=  idUnidadMedida
						from CO_NominacionVolumen
							where Month(idFecha)=@mes and year(idFecha)= @anio  
							and idProductoNominacion=@idProductoNominacion
							and puntoentregaId=@puntoEntrega  
							and idContrato=@idContrato 
							


		--Checa cuantos DÍAs tiene insertado con esos valores para saber si ya esta insertado
			Select @dias= count(VolumenProgramado) 
				from CO_NominacionVolumen
					where Month(idFecha)=@mes and year(idFecha)= @anio
					and idProductoNominacion=@idProductoNominacion
					and puntoentregaId=@puntoEntrega  
					and idContrato=@idContrato 
					

		--verifica si ya fue insertado
			if(@diasCalendario=@dias)
					begin 
					--Que unidad esta insertado
							if(@unidadMedida=1000)
							begin 

							Declare @SumaTotal float;

							--Para suma total con esa unidad de medida (En MMPCD)
							Select @SumaTotal= Sum (VolumenProgramado) 
							from CO_NominacionVolumen 
							where Month(idFecha)=@mes 
							and year(idFecha)= @anio 
							and Month(idFecha)=@mes 
							and year(idFecha)= @anio  
							and idProductoNominacion=@idProductoNominacion 
							and puntoentregaId=@puntoEntrega  
							and idContrato=@idContrato 
							
		
							--Realiza la extraccion de datos para ser visualizados o modificados
							Select day(idFecha) as DÍA, VolumenProgramado as 'Volumen programado (MMPCD)',@Sumatotal as Total, 
							DATENAME(month,idFecha) as mes , Year(idFecha)as anio,TB.nombre as tipoBase, 
							PE.Nombre as puntoentrega,cp.nombre as producto, COA.nombreAreaContractual as bloque,NombreCompleto as director,RazonSocial,CR.nombre as region
							from CO_NominacionVolumen NV
							Join CO_PuntosdeEntrega PE on  NV.PuntoEntregaID=PE.PuntoEntregaID
							Join [CO_TipoBasesNominacion] TB on	NV.idTipoBase=TB.idTipoBase
							Join CO_ClasificacionProductoNominacion CP on NV.idProductoNominacion = CP.ProductoNominacionID
							Join CO_Contrato CC on NV.idContrato = CC.idContrato
							Join CO_AreaContractual COA on CC.IdareaContractual=COA.IdareaContractual
							Join CO_DirectorContrato DC on NV.idDirector=DC.idDirector
							Join CO_DirectorOperaciones DO on NV.idDirector=DO.idDirector
							Join co_Region CR on DC.idRegion=CR.idregion
							where Month(idFecha)=@mes 
							and year(idFecha)= @anio  
							and NV.idProductoNominacion=@idProductoNominacion
							and NV.puntoentregaId=@puntoEntrega  
							and NV.idContrato=@idContrato 
							
				
			


		
					end
			else

					begin 

					--suma en m3 y BBL 
							Declare @Sumam3 float,
									@sumbbl float;

							Select @Sumam3= Sum (VolumenProgramado/ 6.2898105697751), @sumbbl= Sum(VolumenProgramado)  
							from CO_NominacionVolumen
								where Month(idFecha)=@mes and year(idFecha)= @anio 
								and Month(idFecha)=@mes and year(idFecha)= @anio
								and idProductoNominacion=@idProductoNominacion 
								and puntoentregaId=@puntoEntrega  
								and idContrato=@idContrato 
								
		
							--Realiza la extraccion de datos para ser visualizados o modificados

							Select day(idFecha) as DÍA,VolumenProgramado/ 6.2898105697751 as 'Volumen programado (m3)', VolumenProgramado  as 'Volumen programado (BBL)'
							,@Sumam3 as 'total m3', @sumbbl as 'Total BBL', DATENAME(month,idFecha) as mes, Year(idFecha)as anio,
							TB.nombre as tipoBase, 
							PE.Nombre as puntoentrega,cp.nombre as producto, COA.nombreAreaContractual as bloque,NombreCompleto as director,RazonSocial,CR.nombre as region
							from CO_NominacionVolumen NV
							Join CO_PuntosdeEntrega PE on  NV.PuntoEntregaID=PE.PuntoEntregaID
							Join [CO_TipoBasesNominacion] TB on	NV.idTipoBase=TB.idTipoBase
							Join CO_ClasificacionProductoNominacion CP on NV.idProductoNominacion = CP.ProductoNominacionID
							Join CO_Contrato CC on NV.idContrato = CC.idContrato
							Join CO_AreaContractual COA on CC.IdareaContractual=COA.IdareaContractual
							Join CO_DirectorContrato DC on NV.idDirector=DC.idDirector
							Join CO_DirectorOperaciones DO on NV.idDirector=DO.idDirector
							Join co_Region CR on DC.idRegion=CR.idregion
							where Month(idFecha)=@mes 
							and year(idFecha)= @anio 
							and NV.idProductoNominacion=@idProductoNominacion
							and NV.puntoentregaId=@puntoEntrega  
							and NV.idContrato=@idContrato 
							


			
					end
			end
END