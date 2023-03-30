-- =============================================
-- Author:		Reyna Olvera 
-- Create date: 11/01/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE AlteMenuRol
	@bit int,
	@idMenuRol int 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update ap_MenuporRol
	set visible=@bit 
	where idMenuRol=@idMenuRol
END

