-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EstatusDocumentoSGCargado]
@IdProveedor INT,
@IdTipoDocumento INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @EXISTE_DOCUMENTO INT = (SELECT COUNT (IdSistemaGestion) 
	                                 FROM PV_SistemaGestion
									 WHERE IdTipoDocSG = @IdTipoDocumento AND IdProveedor = @IdProveedor AND Activo = 1)

	IF (@EXISTE_DOCUMENTO > 0)
	BEGIN
	SELECT 'EXISTE'
	END
	ELSE
	BEGIN
	SELECT 'DOC_NO_CARGADO'
	END

END

