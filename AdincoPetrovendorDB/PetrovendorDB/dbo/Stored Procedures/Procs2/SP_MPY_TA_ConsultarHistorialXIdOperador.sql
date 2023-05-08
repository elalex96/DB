-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 04-01-17
-- Description:	 Consultar Historial recibiendo el IdOperador
-- =============================================

-- =============================================
-- Author:		Abel Rivera
-- Modified date: 05/03/2018
-- Description:	 Se modificaron los textos para darle el sentido correcto al texto
-- =============================================


CREATE procedure [dbo].[SP_MPY_TA_ConsultarHistorialXIdOperador] 
	-- Add the parameters for the stored procedure here
	@IdAceptacion INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #HistorialFactura
	(
		Fecha DATETIME,
		Accion NVARCHAR(MAX)
	)

	INSERT INTO #HistorialFactura
	SELECT CreadoEl, 'Se Registro la Factura para su Aprobación'
	FROM dbo.MPY_MM_AceptacionFactura
	WHERE IdAceptacionPedido = @IdAceptacion

	INSERT INTO #HistorialFactura
	SELECT APF.FechaEvaluacion, 'El Evaluador ' + APF.Nombre + ' ha ' + CASE APF.EstatusAprobacion 
																			WHEN 2 THEN 'Aprobado'
																			WHEN 3 THEN 'Rechazado'
																		END
	FROM dbo.MPY_FI_Aprobadores AS APF
	WHERE APF.IdAceptacionPedido = @IdAceptacion AND APF.EstatusAprobacion IS NOT NULL
	ORDER BY APF.FechaEvaluacion ASC

	SELECT * FROM #HistorialFactura
END

