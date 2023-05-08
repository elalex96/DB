-- =============================================
-- Author:		Reyna Olvera
-- Create date: 26/04/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE EN_ExtraeEntidades
	-- Add the parameters for the stored procedure here
@idContrato int,
@idusuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select identidad,Entidad from [Cat_General_Entidades]
END