
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <02/07/2017>
-- Description:	<Consulta la infomacion del documento>
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 26-09-2019
-- Description: Add referencias S3
-- =============================================
CREATE PROCEDURE [dbo].[sp_consultarDocumentoSG]
	-- Add the parameters for the stored procedure here
	@TipoDocumento int,
	@IdProveedor int

AS
BEGIN
     
	 SELECT IdSistemaGestion, NombreCertificacion, Activo, Carpeta, Mime, Extension, Identificador, Bucket
	 FROM PV_SistemaGestion
	 WHERE IdProveedor = @IdProveedor AND IdTipoDocSG = @TipoDocumento AND Activo = 1
END

