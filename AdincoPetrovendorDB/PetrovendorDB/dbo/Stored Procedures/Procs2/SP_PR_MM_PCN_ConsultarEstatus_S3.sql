-- =============================================
-- Author:		Daniel Cruz
-- Create date: 31-07-17
-- Description:	CONSULTAR ESTATUS DEL DOCUMENTO DEL LA CARTA DE CONTENIDO NACIONAL
-- =============================================
-- Author:		Luis David
-- Create date: <02/09/2022>
-- Description:	<Se optimiza para el Issue #1986>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PR_MM_PCN_ConsultarEstatus_S3] 
	-- Add the parameters for the stored procedure here

@IdProveedor INT,
@IdAceptacionPedido INT


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 
	 SELECT D.IdDocumento,TU.NombreTipoDocumento, TV.TipoValidacion, D.[CreadoEl] AS FechaAlta,AC_PCN.ComentarioEvaluador, AC_PCN.FechaEvaluacion
	 FROM dbo.S_Documento_S3 (NOLOCK) AS D
	 INNER JOIN MM_AceptacionCartaPCN AS AC_PCN 
		ON D.IdDocumento = AC_PCN.IdDocumento
	 INNER JOIN MM_AceptacionPedido AS AP 
		ON AC_PCN.IdAceptacionPedido = AP.IdAceptacionPedido
	 INNER JOIN MM_Pedido AS P 
		ON AP.IdPedido = P.IdPedido 
	 INNER JOIN S_TipoValidacionDoc (NOLOCK) AS TV 
		ON AC_PCN.IdEstatus = TV.IdTipoValidacionDoc
	 INNER JOIN S_TipoDocumento (NOLOCK) AS TU 
		ON D.IdTipoDocumento = TU.IdTipoDocumento
	 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND P.IdSubcontratista = @IdProveedor
END