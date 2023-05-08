-- =============================================
-- Author:		Reyna Olvera
-- Create date: 13/01/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE AP_CountParaAdminMenu
	-- Add the parameters for the stored procedure here
	@idRol int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select count(idMenuRol) as cant from ap_MenuporRol where visible=1 and idrol=@idRol
END

