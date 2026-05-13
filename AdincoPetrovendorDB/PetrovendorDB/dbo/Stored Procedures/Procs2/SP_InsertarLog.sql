-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertarLog]

@idaccion int,
@idusuario int,
@idcatpag int
	
AS
BEGIN

declare @fecha as datetime = GETDATE()	
	
	SET NOCOUNT ON;

	insert into AP_Bitacora values(@idaccion,@idcatpag,@idusuario,@fecha );

END


