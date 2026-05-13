
-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
create PROCEDURE [dbo].[SP_PV_EliminarClientesPrincipales] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int, 
@IdUsuario int,
@IdClientePrincipales int
 
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE PV_ClientePrincipales
	SET Activo = 0,
	[EditadoPor] = @IdUsuario,
    [EditadoEl] = GETDATE()
	WHERE IdProveedor = @IdProveedor
	AND  IdClientePrincipales = @IdClientePrincipales
	
END


