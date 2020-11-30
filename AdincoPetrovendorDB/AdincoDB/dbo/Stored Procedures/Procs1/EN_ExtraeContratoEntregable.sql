-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EN_ExtraeContratoEntregable]
	-- Add the parameters for the stored procedure here
	@IdContrato int,
	@IdEntregable int,
	@idUsuario int =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select TOP 1 idContratoEntregable from EN_ContratoEntregable
Where idContrato=@IdContrato and idEntregable =@IdEntregable;
END

