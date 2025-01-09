USE [Adinco]
GO
IF OBJECT_ID('Adinco..USP_SEL_AP_S_ConsultarNotificaciones') IS NOT NULL
BEGIN
DROP PROCEDURE USP_SEL_AP_ConsultarNotificaciones;
END
/****** Object:  StoredProcedure [dbo].[USP_SEL_AP_S_ConsultarNotificaciones]    Script Date: 08/01/2025 07:44:53 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <08/01/2025>
-- Description:	<Consulta de notificaciones>
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_AP_ConsultarNotificaciones]
	-- Add the parameters for the stored procedure here
	@IdsNotificaciones VARCHAR(500),
    @SoloPendientes BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #tmpNotificacionesIds (IdNotificacion INT);

    IF (isnull(@IdsNotificaciones, '') <> '')
    BEGIN
        INSERT INTO #tmpNotificacionesIds
        SELECT splitdata
        FROM [dbo].[fnSplitString](@IdsNotificaciones, ',');
    END;
    ELSE
    BEGIN
        INSERT INTO #tmpNotificacionesIds
        SELECT 0;
    END;

    SELECT TOP 20
        N.IdNotificacion,
		Para = N.Para,
        N.Asunto,
        Mensaje = CAST(N.Mensaje AS VARCHAR(MAX)),
        N.FechaProgramadaEnvio,
        N.Enviada,
        N.FechaEnvio,
        TieneError = CASE
                         WHEN max(ne.IdNotificacionError) IS NOT NULL THEN
                             1
                         ELSE
                             0
                     END,
        N.CreadoPor,
        N.CreadoEl,
        N.ModificadoPor,
        N.ModificadoEl,
        N.De,
        IdNotificacionMA = 0,
        N.CCO
    FROM dbo.AP_Notificacion N (NOLOCK)
        INNER JOIN #tmpNotificacionesIds tmp
            ON (
                   tmp.IdNotificacion = n.IdNotificacion
                   OR tmp.IdNotificacion = 0
               )
        LEFT JOIN dbo.S_NotificacionError NE (NOLOCK)
            ON N.IdNotificacion = NE.IdNotificacion
    WHERE N.Enviada = 0
          AND N.FechaProgramadaEnvio <= GETDATE()
          AND ltrim(rtrim(isnull(n.Para, ''))) <> ''
    GROUP BY N.IdNotificacion,
             N.Asunto,
             CAST(N.Mensaje AS VARCHAR(MAX)),
             N.FechaProgramadaEnvio,
             N.Enviada,
             N.FechaEnvio,
             N.CreadoPor,
             N.CreadoEl,
             N.ModificadoPor,
             N.ModificadoEl,
             N.De,
             N.Para,
             N.CCO
    HAVING count(DISTINCT ne.IdNotificacionError) < 3 --Solo se intentará enviar hasta 3 veces un mismo correo
    ORDER BY N.IdNotificacion;
END
