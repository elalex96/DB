USE Petrovendor
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PC_ConsultaContenidoNacional'
)
    DROP PROCEDURE SP_PC_ConsultaContenidoNacional;
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <17/04/2020>
-- Description:	<Consulta de contenido nacional por compra directa>
-- =============================================
-- =============================================
-- Author:		<DanielAc>
-- Create date: <12/11/2025>
-- Description:	<Se aumenta el SUBSTRING a 200>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaContenidoNacional] --1239
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobate INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		CNCD.IdCDCN,
		ISNULL('(' + BS.Codigo + ')' + BS.Nombre ,'NO CONTENIDO') AS ActividadBS,
		SUBSTRING(CNCD.DescripcionBienesServicios,1,200) AS DescripcionBienesServicios,
		ROUND(CNCD.PCN,4) AS PCN,
		ROUND(CNCD.ValorFactura,4) AS ValorFactura, 
		SH.ClasificacionNombreL
	FROM dbo.CN_CompraDirecta AS CNCD
		LEFT JOIN dbo.MM_BS_Actividad AS BS 
			ON CNCD.IdActividadBS = BS.IdActividad 
		LEFT JOIN dbo.CN_ClasificacionContenidoSH AS SH
			ON CNCD.ClasificacionSH = SH.IdClasificacionSH 
	WHERE CNCD.IdPedimentoComprobante = @IdPedimentoComprobate
		AND CNCD.Activo = 1
END
