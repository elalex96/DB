-- =============================================
-- Author:		Reyna O.
-- Create date: 13/02/2018
-- Description: Realiza calculo para la nominacion de acuerdo a la unidad de medicion
-- =============================================
Create PROCEDURE [dbo].[CO_TotalesReporteNominacionMensualWord]
	-- Add the parameters for the stored procedure here
	
@idContrato int,
@idProductoNominacion int,
@puntoEntrega int,
@FechaMesAnio nvarchar(Max)
	--Exec [CO_ReporteNominacionMensualWord] 10024,1000,1004,'2018-02-01'
	--Exec [CO_ReporteNominacionMensualWord] 3,1000,1014,'2018-02-01'
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
		--Cuenta los dias del mes para ese año
		Select @diasCalendario= Count(idFecha)  from ap_Calendario
		 where month(idFecha)=@mes and year (idFecha)=@anio 

		 --Extrae la unidad de medida para saber si se realizara una conversion 
		 Select  Top 1 @unidadMedida=  idUnidadMedida
						from CO_NominacionVolumen
							where Month(idFecha)=@mes and year(idFecha)= @anio  
							and idProductoNominacion=@idProductoNominacion
							and puntoentregaId=@puntoEntrega  
							and idContrato=@idContrato 
							


		--Checa cuantos días tiene insertado con esos valores para saber si ya esta insertado
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
							
		Select @SumaTotal as SumaMMPCD
			


		
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
								
		Select @Sumam3 as SumaMC ,@sumbbl as SumaBBL;
			
					end
			end
END

