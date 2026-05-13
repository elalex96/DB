-- =============================================
-- Author:		DANIEL AC
-- Create date: 05/06/2017
-- Description:	Actualizar Activo 
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_EliminarDomicilio]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdDomicilio int, 
	@IdUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	UPDATE  DG_Domicilio
	SET Activo= 0,
	FechaCambio = GETDATE(),
	IdActualizadoPor = @IdUsuario
	WHERE IdDomicilio = @IdDomicilio and IdProveedor = @IdProveedor
	 

END

