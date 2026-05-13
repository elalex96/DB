-- =============================================
-- Author:		Alexander Gomez
-- Create date: 27/10/2022
-- Description:	Actualizacion de los parametros de 
-- =============================================
CREATE PROCEDURE [dbo].[SP_SM_ActualizarParametros]
	-- Add the parameters for the stored procedure here
	@Id INT,
	@Indicador NVARCHAR(100),
	@MayorA INT,
	@MenorA INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MayorA_Anterior INT = (SELECT MayorA FROM AdincoServerMonitor_Indicadores WHERE Indicador = @Indicador);
	DECLARE @MenorA_Anterior INT = (SELECT MenorA FROM AdincoServerMonitor_Indicadores WHERE Indicador = @Indicador);
	DECLARE @MENSAJE NVARCHAR(MAX) = '';

	IF @MayorA <> @MayorA_Anterior
	BEGIN
		
		SET @MENSAJE = 'Se actualizó el parámetro del indicador "' + @Indicador + '" Máximo de ' + CAST(@MayorA_Anterior AS nvarchar) + '(Anterior) a ' + CAST(@MayorA AS nvarchar) + '(Nuevo).';

	END

	IF @MenorA <> @MenorA_Anterior
	BEGIN
		
		SET @MENSAJE = @MENSAJE + 'Se actualizó el parámetro del indicador "' + @Indicador + '" Mínimo de ' + CAST(@MenorA_Anterior AS nvarchar) + '(Anterior) a ' +  CAST(@MenorA AS nvarchar) + '(Nuevo).';

	END

	UPDATE AdincoServerMonitor_Indicadores
	SET MayorA = @MayorA,
		MenorA = @MenorA
	WHERE Indicador = @Indicador;

	IF @MENSAJE <> ''
	BEGIN

		INSERT INTO BitacoraErrores (HResult,Mensaje, StackTrace, FechaRegistro)
		VALUES
		(0, @MENSAJE,'BITACORA_ADINCO_SERVER_MONITOR_INDICADORES' ,GETDATE());

	END

END
