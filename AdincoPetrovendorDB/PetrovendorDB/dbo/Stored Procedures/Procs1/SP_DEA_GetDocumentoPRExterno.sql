USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_DEA_GetDocumentoPRExterno]    Script Date: 24/09/2021 04:38:04 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <18-09-18>
-- Description:	<obtiene la informacion del documento del factura ya sea xml o pdf>
-- Author:		<Manuel Cruz>
-- Create date: <23/09/20219>
-- Description:	<Se agrega columna Bucket para que devuelva el select descarga estandar avance 5>
-- =============================================
ALTER  PROCEDURE [dbo].[SP_DEA_GetDocumentoPRExterno]
@IdProveedor INT,
@IdUsuario INT,
@IdDocumento INT,
@IdSolicitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT D.NombreDocumento,D.Extension,D.Mime,UPPER(D.Carpeta),D.Identificador,PR.IdSolicitudPedido,PR.ID_PR,D.Bucket
	FROM dbo.DEA_Documento_S3 D
 	LEFT JOIN dbo.DEA_AdjuntoPR PR ON PR.IdAjuntoPr = PR.IdAjuntoPr
	WHERE PR.IdSolicitudPedido = @IdSolicitudPedido	
	AND D.Activo = 1
	ORDER BY D.CreadoEl DESC
END