
-- =============================================
-- Author:		<Unknown>
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <17-08-2018>
-- Description:	<Se agrega a la consulta el Telefono>
-- =============================================

CREATE PROCEDURE [dbo].[SP_ConsultarFlujoCombo]
	(@idFlujo INT)
AS
BEGIN
    SELECT flujo.IdFlujoTarea,
           usuario.Nombre,
           aprobador.NoSecuencia,
		   usuario.Telefono
    FROM dbo.TA_FlujoTarea flujo (NOLOCK)
        INNER JOIN dbo.TA_Aprobador aprobador (NOLOCK)
            ON aprobador.IdFlujoTarea = flujo.IdFlujoTarea
        INNER JOIN dbo.S_Usuario usuario (NOLOCK)
            ON usuario.IdUsuario = aprobador.IdUsuario
    WHERE flujo.Activo = 1
          AND (
                  flujo.IdTipoOperacion = 14
                  OR flujo.IdTipoOperacion = 2
              )
          AND (
                  flujo.Eliminado = 0
                  OR flujo.Eliminado IS NULL
              )
          AND flujo.IdFlujoTarea = @idFlujo;

END;