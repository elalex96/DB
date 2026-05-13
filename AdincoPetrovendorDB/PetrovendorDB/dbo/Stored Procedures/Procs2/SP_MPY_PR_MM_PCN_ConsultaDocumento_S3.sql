-- =============================================
-- Author:		Daniel Cruz
-- Create date: 05-07-17
-- Description:	CONSULTAR CARTA DE CONTENIDO NACIONAL
-- Update: Se le agregaron parametros para obtener el detalle del documento
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 05-07-17
-- Description:	se agrega el bucket 
-- Update: Se agrega el bucket a la consulta para estandarización de la descarga
-- =============================================
CREATE procedure [dbo].[SP_MPY_PR_MM_PCN_ConsultaDocumento_S3] 
	-- Add the parameters for the stored procedure here
@IdDocumento       INT,
@IdAceptacionPedido INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
          
		  SELECT D.Documento, D.Identificador,D.Carpeta,D.Extension, D.NombreDocumento, D.Mime, ISNULL(d.Bucket,'') as Bucket
		  FROM dbo.S_Documento_S3 AS D
		  INNER JOIN MPY_MM_AceptacionCartaPCN AS APC ON APC.IdDocumento = D.IdDocumento
		  INNER JOIN MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		  WHERE AP.IdAceptacionPedido = @IdAceptacionPedido AND D.IdDocumento= @IdDocumento
		 
     END;