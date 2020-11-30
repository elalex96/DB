-- =============================================
-- Author:		Pedro Acuña
-- Create date: 20/09/2018
-- Description:	reemplzar el texto del combo en cascada para que no se quede el id del combo
-- =============================================

CREATE PROCEDURE SP_ADM_ReemplazarTextoCmbSubcontratistaS3 @IdSubcontratista INT
AS
	BEGIN
		SELECT	RazonSocial
		FROM	dbo.S_Proveedor
		WHERE	IdProveedor = @IdSubcontratista
	END