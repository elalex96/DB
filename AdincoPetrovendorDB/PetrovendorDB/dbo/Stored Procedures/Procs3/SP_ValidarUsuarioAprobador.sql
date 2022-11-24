-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarUsuarioAprobador]
@IdUsuario INT,
@IdOperacion INT
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 SELECT 'ES_APROBADOR',TT.IdEstatus 
	 FROM  TA_OPERACION  O 
	 INNER JOIN TA_Tarea TT ON O.IdOperacion =TT.IdOperacion
	 WHERE O.IdOperacion= @IdOperacion AND TT.IdAprobador=@IdUsuario


END
