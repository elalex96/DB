-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AutentificarEquipo]

@nombreEqp varchar(50)

AS
BEGIN

SELECT * FROM AP_Equipo WHERE NombreEquipo = @nombreEqp

END


