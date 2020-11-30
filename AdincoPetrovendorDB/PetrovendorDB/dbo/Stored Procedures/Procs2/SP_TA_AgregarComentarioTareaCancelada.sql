-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_AgregarComentarioTareaCancelada]
@comentario varchar(Max),
@IdOperacion int,
@IdUsario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [TA_ComentariosTareaCancelada](
      [Descripcion],
      [IdOperacion],
      [IdUsuario]
	)
	VALUES(
	@comentario,
    @IdOperacion,
    @IdUsario
	)

	SELECT @@IDENTITY

END

