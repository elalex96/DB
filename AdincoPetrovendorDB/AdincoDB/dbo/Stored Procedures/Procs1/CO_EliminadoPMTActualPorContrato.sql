-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <22/04/2021>
-- Description:	<Eliminado de PMT para cargar el nuevo>
-- =============================================
CREATE PROCEDURE CO_EliminadoPMTActualPorContrato 
	-- Add the parameters for the stored procedure here
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @MESCARGA DATE = CONVERT(date,(CAST(YEAR(GETDATE()) AS nvarchar) + '-' + CAST(MONTH(GETDATE()) AS nvarchar) + '-01'));

	UPDATE CO_CargaProgramadaTrabajo
	SET Activo = 0,
		FechaModificacion = GETDATE()
	WHERE MesCarga = @MESCARGA
		AND IdContrato = @IdContrato;
END