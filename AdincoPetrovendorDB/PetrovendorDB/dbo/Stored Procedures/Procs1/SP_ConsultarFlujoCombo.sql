USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_ConsultarFlujoCombo]    Script Date: 26/11/2021 01:47:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Unknown>
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <17-08-2018>
-- Description:	<Se agrega a la consulta el Telefono>
-- =============================================

ALTER PROCEDURE [dbo].[SP_ConsultarFlujoCombo]
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


