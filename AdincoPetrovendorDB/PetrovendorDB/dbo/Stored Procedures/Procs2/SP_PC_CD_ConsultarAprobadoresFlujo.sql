-- =============================================
-- Author:		DANIEL AC
-- Create date: 17-04-18
-- Description:	Consultar flujo de aprobación de comprobantes 
-- ==========================================
CREATE PROCEDURE [dbo].[SP_PC_CD_ConsultarAprobadoresFlujo] (@idFlujo INT)
AS
BEGIN
    SELECT flujo.IdFlujoTarea,
           usuario.Nombre
    FROM dbo.TA_FlujoTarea flujo
        INNER JOIN dbo.TA_Aprobador aprobador
            ON aprobador.IdFlujoTarea = flujo.IdFlujoTarea
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = aprobador.IdUsuario
    WHERE flujo.Activo = 1
          AND flujo.IdTipoOperacion = 16
          AND (
                  flujo.Eliminado = 0
                  OR flujo.Eliminado IS NULL
              )
          AND flujo.IdFlujoTarea = @idFlujo

END
