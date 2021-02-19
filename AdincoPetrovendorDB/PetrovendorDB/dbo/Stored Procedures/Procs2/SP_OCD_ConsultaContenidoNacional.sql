-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <17/04/2020>
-- Description:	<Consulta de contenido nacional por compra directa>
-- =============================================
-- Author:		<DAVID DE LA CRUZ>
-- Create date: <19/02/2021>
-- Description:	<SE QUIITA EL CONTRATO EN CONSULTA>
-- =============================================
CREATE PROCEDURE [dbo].[SP_OCD_ConsultaContenidoNacional] --19868,11108,420,3
	-- Add the parameters for the stored procedure here
	@IdFactura INT,
	@IdPedido INT,
	@IdProveedor INT,
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT		CNCD.IdCDCN,
				IdActividadBS						=		ISNULL(CNCD.IdActividadBS,0),
				CNCD.DescripcionBienesServicios,
				CNCD.PCN,
				CNCD.ValorFactura, 
				CNCD.ClasificacionSH
	FROM		dbo.CN_CompraDirecta				CNCD
	LEFT JOIN	dbo.MM_BS_Actividad					BS 
	ON			BS.IdActividad						=		CNCD.IdActividadBS
	LEFT JOIN	dbo.CN_ClasificacionContenidoSH		SH
	ON			SH.IdClasificacionSH				=		CNCD.IdCDCN
	WHERE		CNCD.IdPedido						=		@IdPedido
	AND			CNCD.IdFactura						=		@IdFactura
	AND			CNCD.IdProveedor					=		@IdProveedor
	--AND			CNCD.IdContrato						=		@IdContrato
	GROUP BY	CNCD.IdCDCN,
				CNCD.IdActividadBS,
				CNCD.DescripcionBienesServicios,
				CNCD.PCN,
				CNCD.ValorFactura,
				CNCD.ClasificacionSH
END
