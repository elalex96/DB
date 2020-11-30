-- =============================================
-- Author:		Reyna O.
-- Create date: 13/02/18
-- Description:	Para la visualizacion en el sistema y por si requieren ser modificados algunos cambios
-- =============================================
CREATE PROCEDURE [dbo].[CO_NominacionMensual]
	
	@idContrato int,
	--@BloqueId int,
	@idProductoNominacion int,
	@puntoEntrega int,
	@FechaMesAnio nvarchar(Max)
	,@idUsuario int,
	@idDirector int
	
AS
BEGIN
	
	SET NOCOUNT ON;

    
	
	Declare 
	@diasCalendario int,
	@dias int,
	@mes int,
	@anio int;
	----
	
	

	Select @mes= Month(@FechaMesAnio);
	Select @anio= Year(@FechaMesAnio);

	--@idProductoNominacionBloque int;

	--Select @idProductoNominacionBloque= idProductoNominacionBloque 
	--from CO_ProductoNominacionBloque
	-- where BloqueID=@BloqueId and ProductoNominacionID=@ProductoNominacionId;

--Cuenta los dias del mes para ese año
		Select @diasCalendario= Count(idFecha)  
		from ap_Calendario
		where month(idFecha)=@mes and year (idFecha)=@anio;
	
--Checa cuantos días tiene insertado con esos valores para saber si ya esta insertado
			Select @dias= count(idFecha) 
			from CO_NominacionVolumen
			where Month(idFecha)=@mes 
			and year(idFecha)= @anio  
			and idProductoNominacion=@idProductoNominacion
			and idContrato=@idContrato 
			and PuntoEntregaID=@puntoEntrega
			
			--Select * from CO_NominacionVolumen
			--Select @dias

--verifica si ya fue insertado
	if(@diasCalendario=@dias)
	begin 
			--Selecciona lo que ya esta insertado dpendiendo de esos datos y fecha
			Select idNominacionVolumen, day(idFecha) as dia, VolumenProgramado as VolumenProgramado 
			from CO_NominacionVolumen
			where Month(idFecha)=@mes 
			and year(idFecha)= @anio 
			and idProductoNominacion=@idProductoNominacion
			and idContrato=@idContrato 
			and PuntoEntregaID=@puntoEntrega
		

		
	end


	else
	begin 

					--Select idFecha from  ap_calendario where mes=@mes and anio=@anio

			--Inserta nuevos valores con los datos enviados para que en la vista del sistema lleve los datos pero con valor de volumen programado en 0
			--para poder ser modificados
			Insert into CO_NominacionVolumen
				Select Distinct(apC.idFecha),@idProductoNominacion as idProductoNominacion,
				@puntoEntrega as puntoEntregaId, null as idTipoBase,null as VolumenProgramado,
				null as IdUnidadMedida, @idContrato as idContrato,@idDirector as idDirector, @idUsuario as Creadopor,GetDate() as Creadoel,null as modificadopor,null as ModificadoEl, null as activo
					from
					-- CO_NominacionVolumen
					--Cross join  
					ap_calendario apC where mes=@mes and anio=@anio

						Select idNominacionVolumen, day(idFecha) as dia, VolumenProgramado as VolumenProgramado
						 from CO_NominacionVolumen
							where Month(idFecha)=@mes 
							and year(idFecha)= @anio 
							and idProductoNominacion=@idProductoNominacion
							and idContrato=@idContrato 
							and PuntoEntregaID=@puntoEntrega;
						
	end
END

