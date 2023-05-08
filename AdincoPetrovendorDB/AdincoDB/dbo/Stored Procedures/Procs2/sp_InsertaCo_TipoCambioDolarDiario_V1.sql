CREATE PROCEDURE [dbo].[sp_InsertaCo_TipoCambioDolarDiario_V1]
@Fecha varchar(10),
@Fix Decimal (18,4),
@PublicacionDOF Decimal (18,4),
@Parapagos DECIMAL (18,4)
AS
	BEGIN
	DECLARE @RowAffected as int;
	SET NOCOUNT ON;
	BEGIN TRY

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
