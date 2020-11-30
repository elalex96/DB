-- =============================================
-- Author:		DANIEL AC
-- Create date: 28-03-18
-- Description:	Consultar proveedores del proveedores de petrovendor
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_PCN_ConsultarProveedores]
    -- Add the parameters for the stored procedure here

    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	SELECT IdPCNProveedor, RazonSocial, RFC
	FROM dbo.MM_PCN_Proveedor 
	WHERE IdProveedor=@IdProveedor 
	GROUP BY IdPCNProveedor,RFC, RazonSocial
	ORDER BY RazonSocial

END;

