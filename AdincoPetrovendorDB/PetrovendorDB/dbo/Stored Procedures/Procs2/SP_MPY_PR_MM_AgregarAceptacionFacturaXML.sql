-- =============================================
-- Author:		Daniel Cruz
-- Create date: 05-08-17
-- Description:	
-- =============================================
CREATE procedure [dbo].[SP_MPY_PR_MM_AgregarAceptacionFacturaXML] 
	-- Add the parameters for the stored procedure here
@IdProveedor        INT,
@IdAceptacionPedido INT,
@IdFactura INT, 
@IdUsuario INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
	 
		UPDATE  [dbo].[MPY_MM_AceptacionFactura]
		SET [IdFactura]= @IdFactura,
		[IdEstatusXML] = 1003,
		[FechaCargaXML] = GETDATE(),
		[ModificadoPor] = @IdUsuario
		WHERE [IdAceptacionPedido]= @IdAceptacionPedido
		
		SELECT 'UPDATE SUCCESS'

     END
