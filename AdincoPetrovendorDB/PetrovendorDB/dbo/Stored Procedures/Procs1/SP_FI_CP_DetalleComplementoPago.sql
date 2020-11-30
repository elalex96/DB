-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <15/01/2020>
-- Description:	<consulta de los detalles de un complemento de pago>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_CP_DetalleComplementoPago] --10325
	-- Add the parameters for the stored procedure here
	@IdComplementoPago INT,
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @UUID NVARCHAR(100) = (SELECT UUID FROM dbo.FI_Factura WHERE IdFactura = @IdFactura);

	SELECT
		CP.IdComplementoDePago,
		F.IdFactura,
		F.UUID,
		F.Emisor,
		FORMAT(F.Fecha,'dd/MM/yyyy HH:mm:ss tt') AS Fecha,
		DRCP.MetodoDePagoDR,
		FORMAT(CP.FechaDePago,'dd/MM/yyyy HH:mm:ss tt') AS FechaDePago,
		CP.MonedaP,
		DRCP.ImpPagado,
		F.XML AS XMLTexto
	INTO #COMPLEMENTOSPAGO
	FROM Adinco.dbo.FI_ComplementoDePago AS CP
		LEFT JOIN Adinco.dbo.FI_CPDocRelacionado AS DRCP 
			ON DRCP.IdComplementoDePago = CP.IdComplementoDePago
		LEFT JOIN Adinco.dbo.FI_Factura AS F 
			ON F.IdFactura = CP.IdFactura
	WHERE CP.IdComplementoDePago = @IdComplementoPago
		AND DRCP.IdDocumento = @UUID
	--ORDER BY DRCP.ImpPagado ASC

	SELECT
		IdComplementoDePago,
		IdFactura,
		UUID,
		Emisor,
		Fecha,
		MetodoDePagoDR,
		FechaDePago,
		MonedaP,
		ImpPagado,
		XMLTexto
	FROM #COMPLEMENTOSPAGO
	--ORDER BY ImpPagado ASC

END