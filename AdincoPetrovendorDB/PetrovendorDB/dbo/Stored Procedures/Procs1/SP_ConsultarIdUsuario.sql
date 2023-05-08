-- =============================================
-- Author:		Abel Rivera
-- Create date: 06/09/2017
-- Description:	SP para obtener el Id del Usuario que se acaba de registrar 
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarIdUsuario]

@correo varchar(max)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select IdUsuario from S_Usuario where Correo = @correo

END

