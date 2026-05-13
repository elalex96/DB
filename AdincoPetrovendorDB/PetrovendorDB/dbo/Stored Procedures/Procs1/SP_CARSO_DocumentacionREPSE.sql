-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <10/03/2022>
-- Description:	<Consulta de documentacion repse>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CARSO_DocumentacionREPSE]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @NOMBRETIPODOCUMENTO INT; 
	SET @NOMBRETIPODOCUMENTO = (SELECT TOP 1 IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = 'Certificado de aprobación de REPSE');

	SELECT
		PR.RazonSocial AS Proveedor,
		PR.FechaVigenciaREPSE AS FechaInicioVigenciaREPSE,
		DATEADD(YEAR,3,PR.FechaVigenciaREPSE) AS FechaFinVigenciaREPSE,
		DOC.IdDocumento
	FROM MM_SolicitudPedido AS SP
		JOIN MM_PeticionOferta AS PO
			ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
				AND PO.Activo = 1
		LEFT JOIN S_Proveedor AS PR 
			ON PO.IdSubcontratista = PR.IdProveedor
			AND PR.Activo = 1
		LEFT JOIN S_Documento_S3 AS DOC
			ON PR.IdProveedor = DOC.IdProveedor
			AND DOC.Activo = 1
			AND DOC.IdTipoDocumento = @NOMBRETIPODOCUMENTO
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido;

END