-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21/04/2021>
-- Description:	<Consulta de los ultimos cambios del mes para PMT>
-- =============================================
CREATE PROCEDURE [dbo].[CO_ConsultarPMTActualPorContrato] --3
	-- Add the parameters for the stored procedure here
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @ULTIMOMESCARGADO DATE = (SELECT TOP 1 MesCarga FROM dbo.CO_CargaProgramadaTrabajo WHERE IdContrato = @IdContrato ORDER BY MesCarga DESC);

	SELECT 
		Actividad,
		Unidad,
		Cantidad,
		UnidadesActividad,
		UnidadesTrabajo,
		Estatus
	FROM CO_CargaProgramadaTrabajo
	WHERE IdContrato = @IdContrato
		AND MesCarga = @ULTIMOMESCARGADO
		AND Activo = 1;
	
END
