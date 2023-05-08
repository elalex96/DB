-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ============================================
CREATE PROCEDURE [dbo].[SP_EliminarContactoPA]
@IdContacto int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Update S_Contacto_PA 
	set IsEliminado = 1
	where IdContacto = @IdContacto

	select 'eliminado'
END

