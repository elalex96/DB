-- =============================================
-- Author:		Reyna O
-- Create date: 15/02/2017
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CO_LogoImagen]
	-- Add the parameters for the stored procedure here
	@IdContrato int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	Select logo as logo
from CO_Contratista CCA
JOIN CO_Contrato CCO on CCA.IdContratista=CCO.IdContratista
where idContrato=@IdContrato

--Select foto from ap_Usuario where UsuarioID=2

END

