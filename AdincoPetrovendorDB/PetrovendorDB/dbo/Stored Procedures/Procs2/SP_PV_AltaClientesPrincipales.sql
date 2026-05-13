
-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_AltaClientesPrincipales] 
	-- Add the parameters for the stored procedure here

@IdProveedor int, 
@IdUsuario int,
@NombreCliente NVARCHAR(350),
@RFC  NVARCHAR(350)
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[PV_ClientePrincipales](NombreCliente, IdProveedor, Activo, CreadoPor, CreadoEl,RFC)
	VALUES(@NombreCliente,@IdProveedor,1,@IdUsuario,GETDATE(),@RFC)
	
END


