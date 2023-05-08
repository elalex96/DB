
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 14/09/17
-- Description:	extrae coordenadas para area contractual
-- =============================================
CREATE PROCEDURE [dbo].[Sp_CO_AreaContractual]
	-- Add the parameters for the stored procedure here
	@idArea int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select lat,lng from  CO_Coordenadas 
where idareacontractual = @idArea;
END

