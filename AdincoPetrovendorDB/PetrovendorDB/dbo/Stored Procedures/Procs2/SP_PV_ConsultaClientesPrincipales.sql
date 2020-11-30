

-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaClientesPrincipales] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int 
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT   [IdClientePrincipales],[NombreCliente],[RFC]
	FROM  [dbo].[PV_ClientePrincipales]
	WHERE IdProveedor = @IdProveedor
	AND Activo = 1
	
END
--SELECT  [IdMarca],[NombreMarca] , [ImagenMarca]
--	FROM [dbo].[PV_ProveedorRepresentaMarca]
--	WHERE IdProveedor = @IdProveedor
--	AND Activo = 1
	


