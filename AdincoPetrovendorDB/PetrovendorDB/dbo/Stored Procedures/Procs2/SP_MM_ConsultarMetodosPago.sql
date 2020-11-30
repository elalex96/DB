-- =============================================
-- Author:  Daniel AC
-- Create date: 16-10-2019
-- Description:Consultar métodos de pago
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarMetodosPago] --2822,44
	-- Add the parameters for the stored procedure here
	@IdProveedor INT

AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets  from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;
		
		SELECT IdCondicionPago, CondicionPago 
		FROM MM_CondicionPago
		WHERE Activo=1
	
	END
