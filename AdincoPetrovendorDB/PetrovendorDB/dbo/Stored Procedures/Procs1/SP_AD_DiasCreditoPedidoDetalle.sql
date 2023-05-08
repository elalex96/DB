-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <31/03/2021>
-- Description:	<Consulta de los dias de credito para edicion>
-- ============================================
CREATE PROCEDURE [dbo].[SP_AD_DiasCreditoPedidoDetalle]
	-- Add the parameters for the stored procedure here
	@IdPedido INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT
		PD.IdPedidoDetalle,
		PD.IdMaterial,
		PD.Cantidad,
		M.DescripcionCorta,
		PD.DiasCredito,
		ComentarioEdicion,
		EditadoPorDC AS EditadoPor
	FROM dbo.MM_PedidoDetalle AS PD 
		JOIN dbo.MM_Material AS M ON PD.IdMaterial = M.IdMaterial
	WHERE PD.IdPedido = @IdPedido

END