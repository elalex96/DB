-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AsociarUsEqp]
@NombreUsuario varchar(50),
@NombreEquipo varchar(50)

AS
BEGIN


DECLARE @FechaRegistro as datetime = GETDATE()
DECLARE @Activo bit = '0'


SET NOCOUNT ON;

INSERT INTO AP_UsuarioEquipo(
IdUsuario,
IdEquipo,
FechaRegistro,
Activo
)
SELECT 
IdUsuario,
IdEquipo,
@FechaRegistro,
@Activo
FROM 
S_Usuario,AP_Equipo 
WHERE
S_Usuario.Correo = @NombreUsuario AND AP_Equipo.NombreEquipo = @NombreEquipo

END


