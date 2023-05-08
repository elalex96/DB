-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:Extrae Responsables
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ExtraeResponsables] -- 16841,10061,3,10002,10001
    @IdContratoEntregable INT,
    @idUsuario INT,
    @idContrato INT,
    @idEstatus INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT idUsuario,
           Nombre,
           Usuario
      FROM EN_Actividad
      JOIN dbo.AP_Usuario
        ON UsuarioID = idUsuario
     WHERE EstadoID             = @idEstatus
       AND IdContratoEntregable = @IdContratoEntregable
	   AND Activo=1
     ORDER BY CreadoEN ASC;

END;
