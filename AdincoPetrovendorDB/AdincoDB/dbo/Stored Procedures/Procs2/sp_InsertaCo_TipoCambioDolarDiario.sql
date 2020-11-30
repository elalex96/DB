CREATE PROCEDURE [dbo].[sp_InsertaCo_TipoCambioDolarDiario]
@Fecha DATE, --varchar(10),
@Fix DECIMAL (18,4),
@PublicacionDOF DECIMAL (18,4),
@Parapagos DECIMAL (18,4)
AS
	BEGIN
	DECLARE @RowAffected as int;
	SET NOCOUNT ON;
	BEGIN TRY
	SET LANGUAGE spanish
/*Tabla CO_TipoCambioDiario*/
IF EXISTS(SELECT * FROM [dbo].[CO_TipoCambioDiario] where [Fecha] = cast(convert(datetime, @Fecha, 103) as date) AND IdMoneda = 1)
	BEGIN
		UPDATE [dbo].[CO_TipoCambioDiario]
		SET  [IdMoneda] = 1, [TipoCambio] = @Parapagos, [IdUsuario] = 1, [Activo] = 1, [CreadoPor] = 1
			WHERE Fecha = cast(convert(datetime, @Fecha, 103) as date) AND IdMoneda = 1
			--PRINT 'UPDATE';
END
	ELSE
		BEGIN 
			INSERT INTO [dbo].[CO_TipoCambioDiario]
			([IdMoneda]
			,[Fecha]
			,[TipoCambio]
			,[IdUsuario]
			,[Activo]
			,[CreadoPor])
		VALUES (1,cast(convert(datetime, @Fecha, 103) as date),@Parapagos,1,1,1)
			--PRINT 'INSERT';
END
IF EXISTS(SELECT * FROM dbo.Co_TipoCambioDolarDiario where [Fecha] = cast(convert(datetime, @Fecha, 103) as date))
	BEGIN
		UPDATE dbo.CO_TipoCambioDolarDiario
		SET [FIX] = @FIX, [PublicacionDOF] = @PublicacionDOF, [ParaPagos] = @Parapagos
			WHERE Fecha = cast(convert(datetime, @Fecha, 103) as date);
			--PRINT 'UPDATE';

END
	ELSE
		BEGIN 
			INSERT INTO [dbo].[CO_TipoCambioDolarDiario]
			([Fecha]
			,[FIX]
			,[PublicacionDOF]
			,[ParaPagos])
		VALUES (cast(convert(datetime, @Fecha, 103) as date), @FIX, @PublicacionDOF, @Parapagos)
			--PRINT 'INSERT';
END

select @RowAffected= @@ROWCOUNT
 select @RowAffected as FilasAfectadas;
 END try
 	BEGIN CATCH
	SELECT   
	 ERROR_NUMBER() AS NumeroError  	
	,ERROR_PROCEDURE() AS ProcedimientoError  
	,ERROR_LINE() AS LineaError  
	,ERROR_MESSAGE() AS MensajeError;   
	END CATCH
END