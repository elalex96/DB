-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14-06-17
-- Description:	CONSULTAR ESTATUS DEL DOCUMENTO DEL LA CARTA DE CONTENIDO NACIONAL
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MPY_PR_MM_PCN_ConsultarEstatus_S3] 
	-- Add the parameters for the stored procedure here

@IdProveedor NVARCHAR(20),
@IdAceptacionPedido INT


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 
	 SELECT D.IdDocumento,TU.NombreTipoDocumento, TV.TipoValidacion, D.[CreadoEl] AS FechaAlta,AC_PCN.ComentarioEvaluador, AC_PCN.FechaEvaluacion
	 FROM dbo.S_Documento_S3 AS D
	 INNER JOIN MPY_MM_AceptacionCartaPCN AS AC_PCN ON AC_PCN.IdDocumento = D.IdDocumento
	 INNER JOIN MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AC_PCN.IdAceptacionPedido
	 INNER JOIN S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc =AC_PCN.IdEstatus
	 INNER JOIN S_TipoDocumento  AS TU ON TU.IdTipoDocumento = D.IdTipoDocumento
	 WHERE AP.IdAceptacionPedido = @IdAceptacionPedido --AND AP.IdSubcontratista = @IdProveedor
	 
	 
END
  
