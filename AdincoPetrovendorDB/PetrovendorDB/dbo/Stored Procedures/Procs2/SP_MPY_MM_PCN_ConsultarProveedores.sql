-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14-06-18
-- Description:	Consultar proveedores del proveedores de petrovendor
-- =============================================
CREATE procedure [dbo].[SP_MPY_MM_PCN_ConsultarProveedores]
    -- Add the parameters for the stored procedure here

    @IdProveedor NVARCHAR(20),
    @IdContrato INT,
    @IdUsuario INT

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	SELECT IdPCNProveedor, RazonSocial, RFC
	FROM dbo.MPY_MM_PCN_Proveedor 
	WHERE IdProveedor=@IdProveedor 
	GROUP BY IdPCNProveedor,RFC, RazonSocial
	ORDER BY RazonSocial

END;

