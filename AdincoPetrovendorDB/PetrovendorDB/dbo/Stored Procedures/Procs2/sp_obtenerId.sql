-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[sp_obtenerId]
(
@nombre varchar(50)
)
AS
BEGIN

SET NOCOUNT ON;

SELECT IdUsuario FROM S_Usuario WHERE Correo = @nombre

END

