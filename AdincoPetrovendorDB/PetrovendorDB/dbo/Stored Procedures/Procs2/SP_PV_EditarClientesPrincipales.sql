
-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_EditarClientesPrincipales] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int, 
@IdUsuario int,
@IdClientePrincipales int,
@NombreCliente nvarchar(max),
@RFC  nvarchar(max)
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE PV_ClientePrincipales
	SET NombreCliente = @NombreCliente,
	[EditadoPor] = @IdUsuario,
    [EditadoEl] = GETDATE(),
	RFC = @RFC
	WHERE IdProveedor = @IdProveedor
	AND  IdClientePrincipales = @IdClientePrincipales
	
END


