-- =============================================
-- Author:		Manuel Cruz
-- Create date: 25/08/2021
-- Description:	Devuelve los proveedores para registrar descripción SAP
-- =============================================
CREATE PROCEDURE SP_DEAProveedores
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdProveedor, UPPER(CONCAT(RazonSocial, ', RFC: ', RFC)) AS Proveedor
	FROM S_Proveedor
	WHERE ISNULL(Activo,0) = 1 
	AND ISNULL(IsEliminado,0) = 0
	ORDER BY Proveedor
END
