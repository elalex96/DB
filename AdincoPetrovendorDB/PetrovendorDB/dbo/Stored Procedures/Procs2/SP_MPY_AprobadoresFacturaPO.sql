
 USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_MPY_AprobadoresFacturaPO
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/11/2018
-- Description:	Consultar los aprobadores de factura
-- =============================================
-- Author:		Luis David
-- Create date: 08/06/2022
-- Description:	Se agrega el id proveedor para validar si se bloqueó el correo Issue 1780
-- =============================================
CREATE procedure [dbo].[SP_MPY_AprobadoresFacturaPO] --'4500095093'
	-- Add the parameters for the stored procedure here
	@PONumber VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure her
	DECLARE @RFCCONTRATISTA VARCHAR(50) = (SELECT TOP 1
													CO.RFC
												FROM Adinco.dbo.CO_SAPPO AS PO
													LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS CSP ON CSP.Planta = PO.Plant
													LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = CSP.IdContratista
												WHERE PO.SAPPONumber = @PONumber
												GROUP BY CO.RFC);

	DECLARE @VENDORNAME VARCHAR(50) = (SELECT TOP 1
													V.VendorName
												FROM Adinco.dbo.CO_SAPPO AS PO
													LEFT JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PO.SAPVendorNumber
												WHERE PO.SAPPONumber = @PONumber);
	DECLARE @IDPROVEEDOR INT = (SELECT TOP 1 UP.IdProveedor
												FROM Adinco.dbo.CO_SAPPO AS PO
													JOIN Petrovendor.dbo.S_UsuarioProveedor AS UP
													on Po.IdContrato = UP.IdContrato
												WHERE PO.SAPPONumber = @PONumber
												GROUP BY IdProveedor);
												

	
	SELECT
		US.IdUsuario,
		US.Nombre,
		US.Correo,
		@VENDORNAME AS VendorName,
		@IDPROVEEDOR AS IdProveedor
	FROM dbo.S_Usuario AS US
		LEFT JOIN dbo.S_UsuarioProveedor AS UP ON UP.IdUsuario = US.IdUsuario
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = UP.IdProveedor
	WHERE PR.RFC = @RFCCONTRATISTA
		AND US.Activo = 1
		AND (US.IdTipoUsuario = 5 OR US.IdTipoUsuario = 6 OR US.IdTipoUsuario = 3)
	GROUP BY US.IdUsuario,
		US.Nombre,
		US.Correo

END
