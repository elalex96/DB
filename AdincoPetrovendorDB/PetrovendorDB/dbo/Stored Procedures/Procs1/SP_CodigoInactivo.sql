-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CodigoInactivo]
@codActivacion varchar(100)
AS
BEGIN

	SET NOCOUNT ON;

	update AP_CodActivacion set Activo = '1' where CodigoActivacion = @codActivacion

END


