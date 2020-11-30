-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <11-09-2018>
-- Description:	<llenar el combo de Requisiciones en la carga del timeline>
-- =============================================

CREATE PROCEDURE ADM_CmbRequisicionS3 @IdProveedor INT
AS
	BEGIN
		SELECT	TAO.IdDocumento AS IdSolPed,TAO.IdDocumento, TAO.Descripcion
		FROM	dbo.TA_Operacion TAO
		WHERE
				TAO.IdTipoOperacion = 2
				AND TAO.IdProveedor = @IdProveedor
				AND ISNULL ( TAO.IdEstatusEliminado, 0 ) = 0
	END