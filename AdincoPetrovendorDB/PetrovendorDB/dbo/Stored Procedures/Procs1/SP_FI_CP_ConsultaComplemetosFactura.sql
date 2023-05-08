-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <14/01/2020>
-- Description:	<consulta los complementos relacionados a una factura>
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_CP_ConsultaComplemetosFactura] --18522
	-- Add the parameters for the stored procedure here
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to preveant extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	
	SELECT
		CP.IdComplementoDePago,
		FC.UUID,
		CPDR.ImpPagado,
		CPDR.MonedaDR
	INTO #TEMPDOCRELACIONADO
	FROM dbo.FI_Factura AS FP
		LEFT JOIN Adinco.dbo.FI_CPDocRelacionado AS CPDR
			ON CPDR.IdDocumento COLLATE SQL_Latin1_General_CP1_CI_AS = FP.UUID
		LEFT JOIN Adinco.dbo.FI_ComplementoDePago AS CP
			ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
		LEFT JOIN Adinco.dbo.FI_Factura AS FC
			ON FC.IdFactura = CP.IdFactura
	WHERE FP.IdFactura = @IdFactura;
	
	SELECT
		IdComplementoDePago,
		UUID,
		ImpPagado,
		MonedaDR
	FROM #TEMPDOCRELACIONADO

END